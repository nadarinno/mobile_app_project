const {logger} = require('firebase-functions');
const {onCall} = require('firebase-functions/v2/https');
const {onDocumentCreated, onDocumentUpdated} = require('firebase-functions/v2/firestore');
const admin = require('firebase-admin');

admin.initializeApp();


exports.createPaymentIntent = onCall({region: 'us-central1'}, async (request) => {
  const {data} = request;
  try {
    if (!process.env.STRIPE_SECRET_KEY) {
      logger.error('Stripe secret key is not set in environment variables');
      throw new Error('Stripe configuration error');
    }
    logger.info('Stripe secret key loaded successfully');
    const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);


    if (!data.amount || !data.currency) {
      throw new Error('Amount and currency are required');
    }


    if (!Number.isInteger(data.amount) || data.amount <= 0) {
      throw new Error('Amount must be a positive integer');
    }

    const paymentIntent = await stripe.paymentIntents.create({
      amount: data.amount,
      currency: data.currency.toLowerCase(),
      payment_method_types: ['card'],
      metadata: {firebase_callable: 'createPaymentIntent'},
    });

    return {clientSecret: paymentIntent.client_secret};
  } catch (error) {
    logger.error('Stripe Error:', error);
    throw new Error('Payment processing failed: ' + error.message);
  }
});


exports.sendNewProductNotification = onDocumentCreated('products/{productId}', async (event) => {
  const product = event.data.data();
  const productName = product.name || 'New Product';

  const message = {
    notification: {
      title: productName,
      body: `A new product "${productName}" has ` +
            been added!,
    },
    data: {
      type: 'new_product',
      productName,
      message: `A new product "${productName}" has ` +
              been added!,
    },
    topic: 'new_products',
  };

  try {
    const response = await admin.messaging().send(message);
    logger.info('Successfully sent new product notification:', response);
  } catch (error) {
    logger.error('Error sending new product notification:', error);
  }
});


exports.sendOrderUpdateNotification = onDocumentUpdated('orders/{orderId}', async (event) => {
  const after = event.data.after.data();
  const before = event.data.before.data();

  if (after.status !== before.status) {
    const customerId = after.customerId;
    const productName = after.productName || 'Your order';
    const status = after.status;

    const payload = {
      notification: {
        title: productName,
        body: Your order has been updated to: ${status},
      },
      data: {
        type: 'order_update',
        productName,
        message: Your order has been updated to: ${status},
        customerId,
      },
    };

    try {
      await admin.messaging().sendToTopic(order_updates_${customerId}, payload);
      logger.info('Successfully sent order update notification');
    } catch (error) {
      logger.error('Error sending order update notification:', error);
    }
  }
});