const express = require('express');
const app = express();

// GET APIs
app.get('/menu', (req, res) => {
    res.send('<html><body>INSIDE MENU API - Get All Food Items</body></html>');
});
app.get('/restaurants', (req, res) => {
    res.send('<html><body>INSIDE RESTAURANTS API - Get All Restaurants</body></html>');
});
app.get('/orders', (req, res) => {
    res.send('<html><body>INSIDE ORDERS API - Get All Orders</body></html>');
});

// NEW APIs
app.post('/addorder', (req, res) => {
    res.send('<html><body>INSIDE ADD ORDER API - New Order Created</body></html>');
});
app.put('/updateorder', (req, res) => {
    res.send('<html><body>INSIDE UPDATE ORDER API - Order Updated</body></html>');
});
app.delete('/cancelorder', (req, res) => {
    res.send('<html><body>INSIDE CANCEL ORDER API - Order Cancelled</body></html>');
});

app.listen(3000, () =>
    console.log('FoodExpress Server Started at Port No: 3000'));