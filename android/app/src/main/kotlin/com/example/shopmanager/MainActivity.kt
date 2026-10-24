package com.example.shopmanager

import android.os.Build
import android.os.Handler
import android.os.Looper
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyInfo
import android.security.keystore.KeyProperties
import android.util.Base64
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.security.KeyFactory
import java.security.KeyPairGenerator
import java.security.KeyStore
import java.security.PrivateKey
import java.security.SecureRandom
import java.security.Signature
import java.security.spec.ECGenParameterSpec
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val CHANNEL = "shopmanager/device_key"
    private val KEY_ALIAS = "shopmanager_device_key_v1"
    private val ANDROID_KEYSTORE = "AndroidKeyStore"
    private val executor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            executor.execute {
                handleMethodCall(call, result)
            }
        }
    }

    private fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            mainHandler.post {
                result.error(
                    "DEVICE_UNSUPPORTED",
                    "Android 6.0 (API 23) or higher is required for hardware-backed device keys.",
                    null
                )
            }
            return
        }

        try {
            when (call.method) {
                "getDeviceKey" -> {
                    val keyStore = KeyStore.getInstance(ANDROID_KEYSTORE).apply { load(null) }
                    var securityLevel = "unknown"

                    if (!keyStore.containsAlias(KEY_ALIAS)) {
                        // Generate EC key pair (try StrongBox first if API 28+, then fall back)
                        securityLevel = generateEcKeyPair()
                    } else {
                        securityLevel = determineSecurityLevel(keyStore)
                    }

                    val certificate = keyStore.getCertificate(KEY_ALIAS)
                    if (certificate == null) {
                        mainHandler.post {
                            result.error("KEY_MISSING", "Failed to retrieve certificate from Keystore.", null)
                        }
                        return
                    }

                    val publicKey = certificate.publicKey
                    val derBytes = publicKey.encoded
                    val base64Der = Base64.encodeToString(derBytes, Base64.NO_WRAP)

                    mainHandler.post {
                        result.success(
                            mapOf(
                                "publicKeyDer" to base64Der,
                                "securityLevel" to securityLevel
                            )
                        )
                    }
                }
                "proveKeyUsable" -> {
                    val keyStore = KeyStore.getInstance(ANDROID_KEYSTORE).apply { load(null) }
                    if (!keyStore.containsAlias(KEY_ALIAS)) {
                        mainHandler.post {
                            result.error("KEY_MISSING", "Device key has not been generated.", null)
                        }
                        return
                    }

                    val privateKey = keyStore.getKey(KEY_ALIAS, null) as? PrivateKey
                    val certificate = keyStore.getCertificate(KEY_ALIAS)
                    val publicKey = certificate?.publicKey

                    if (privateKey == null || publicKey == null) {
                        mainHandler.post {
                            result.error("KEY_UNUSABLE", "Private key or certificate not available.", null)
                        }
                        return
                    }

                    // Generate random 32-byte challenge
                    val challenge = ByteArray(32)
                    SecureRandom().nextBytes(challenge)

                    // Sign challenge
                    val signer = Signature.getInstance("SHA256withECDSA")
                    signer.initSign(privateKey)
                    signer.update(challenge)
                    val signature = signer.sign()

                    // Verify signature
                    val verifier = Signature.getInstance("SHA256withECDSA")
                    verifier.initVerify(publicKey)
                    verifier.update(challenge)
                    val isValid = verifier.verify(signature)

                    if (isValid) {
                        mainHandler.post { result.success(true) }
                    } else {
                        mainHandler.post {
                            result.error("KEY_UNUSABLE", "Signature self-verification failed.", null)
                        }
                    }
                }
                else -> {
                    mainHandler.post { result.notImplemented() }
                }
            }
        } catch (e: Exception) {
            mainHandler.post {
                result.error("KEYSTORE_UNAVAILABLE", e.message ?: "Keystore operation failed.", null)
            }
        }
    }

    private fun generateEcKeyPair(): String {
        var usedStrongBox = false
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            try {
                val strongBoxBuilder = KeyGenParameterSpec.Builder(
                    KEY_ALIAS,
                    KeyProperties.PURPOSE_SIGN
                )
                    .setAlgorithmParameterSpec(ECGenParameterSpec("secp256r1"))
                    .setDigests(KeyProperties.DIGEST_SHA256)
                    .setUserAuthenticationRequired(false)
                    .setIsStrongBoxBacked(true)

                val keyPairGenerator = KeyPairGenerator.getInstance(
                    KeyProperties.KEY_ALGORITHM_EC,
                    ANDROID_KEYSTORE
                )
                keyPairGenerator.initialize(strongBoxBuilder.build())
                keyPairGenerator.generateKeyPair()
                usedStrongBox = true
            } catch (e: Exception) {
                // StrongBox not available on this device; fall back to standard TEE
            }
        }

        if (!usedStrongBox) {
            val standardBuilder = KeyGenParameterSpec.Builder(
                KEY_ALIAS,
                KeyProperties.PURPOSE_SIGN
            )
                .setAlgorithmParameterSpec(ECGenParameterSpec("secp256r1"))
                .setDigests(KeyProperties.DIGEST_SHA256)
                .setUserAuthenticationRequired(false)

            val keyPairGenerator = KeyPairGenerator.getInstance(
                KeyProperties.KEY_ALGORITHM_EC,
                ANDROID_KEYSTORE
            )
            keyPairGenerator.initialize(standardBuilder.build())
            keyPairGenerator.generateKeyPair()
        }

        val keyStore = KeyStore.getInstance(ANDROID_KEYSTORE).apply { load(null) }
        return determineSecurityLevel(keyStore, usedStrongBox)
    }

    private fun determineSecurityLevel(keyStore: KeyStore, hintStrongBox: Boolean = false): String {
        if (hintStrongBox) return "strongbox"
        try {
            val privateKey = keyStore.getKey(KEY_ALIAS, null) ?: return "unknown"
            val factory = KeyFactory.getInstance(privateKey.algorithm, ANDROID_KEYSTORE)
            val keyInfo = factory.getKeySpec(privateKey, KeyInfo::class.java)

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                return when (keyInfo.securityLevel) {
                    KeyProperties.SECURITY_LEVEL_STRONGBOX -> "strongbox"
                    KeyProperties.SECURITY_LEVEL_TRUSTED_ENVIRONMENT -> "hardware"
                    KeyProperties.SECURITY_LEVEL_SOFTWARE -> "software"
                    else -> if (keyInfo.isInsideSecureHardware) "hardware" else "software"
                }
            } else {
                return if (keyInfo.isInsideSecureHardware) "hardware" else "software"
            }
        } catch (e: Exception) {
            return "unknown"
        }
    }
}
