package com.example.rescunetapp

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.telephony.SmsManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class SmsHandler {
    companion object {
        private const val CHANNEL = "rescuenet/sms"

        fun registerWith(flutterEngine: FlutterEngine, context: Context) {
            val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "sendSms" -> {
                        val phoneNumber = call.argument<String>("phoneNumber")
                        val message = call.argument<String>("message")

                        if (phoneNumber != null && message != null) {
                            val success = sendSms(context, phoneNumber, message)
                            result.success(success)
                        } else {
                            result.error("INVALID_ARGUMENTS", "Phone number and message are required", null)
                        }
                    }
                    "canSendSms" -> {
                        result.success(true)
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
        }

        private fun sendSms(context: Context, phoneNumber: String, message: String): Boolean {
            return try {
                val smsManager = SmsManager.getDefault()
                
                // For messages longer than 160 characters, split into multiple parts
                val parts = smsManager.divideMessage(message)
                
                if (parts.size > 1) {
                    // Send multipart message
                    val sentIntents = ArrayList<PendingIntent>()
                    val deliveryIntents = ArrayList<PendingIntent>()
                    
                    for (i in parts.indices) {
                        sentIntents.add(PendingIntent.getBroadcast(
                            context,
                            0,
                            Intent("SMS_SENT"),
                            PendingIntent.FLAG_IMMUTABLE
                        ))
                        deliveryIntents.add(PendingIntent.getBroadcast(
                            context,
                            0,
                            Intent("SMS_DELIVERED"),
                            PendingIntent.FLAG_IMMUTABLE
                        ))
                    }
                    
                    smsManager.sendMultipartTextMessage(
                        phoneNumber,
                        null,
                        parts,
                        sentIntents,
                        deliveryIntents
                    )
                } else {
                    // Send single message
                    val sentIntent = PendingIntent.getBroadcast(
                        context,
                        0,
                        Intent("SMS_SENT"),
                        PendingIntent.FLAG_IMMUTABLE
                    )
                    val deliveryIntent = PendingIntent.getBroadcast(
                        context,
                        0,
                        Intent("SMS_DELIVERED"),
                        PendingIntent.FLAG_IMMUTABLE
                    )
                    
                    smsManager.sendTextMessage(
                        phoneNumber,
                        null,
                        message,
                        sentIntent,
                        deliveryIntent
                    )
                }
                
                true
            } catch (e: Exception) {
                e.printStackTrace()
                false
            }
        }
    }
}
