#!/bin/bash

echo "~~~~~ MY SALON ~~~~~"
echo ""
echo "Welcome to My Salon, how can I help you?"
echo ""

while true; do
  psql --username=freecodecamp --dbname=salon -t -A -c "SELECT service_id, name FROM services ORDER BY service_id;" | sed 's/|/) /'
  
  read SERVICE_ID_SELECTED
  
  SERVICE_NAME=$(psql --username=freecodecamp --dbname=salon -t -A -c "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
  
  if [ -z "$SERVICE_NAME" ]; then
    echo "I could not find that service. What would you like today?"
    echo ""
  else
    break
  fi
done

echo "What's your phone number?"
read CUSTOMER_PHONE

CUSTOMER_ID=$(psql --username=freecodecamp --dbname=salon -t -A -c "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")

if [ -z "$CUSTOMER_ID" ]; then
  echo "I don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  
  psql --username=freecodecamp --dbname=salon -c "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME');" > /dev/null
  
  CUSTOMER_ID=$(psql --username=freecodecamp --dbname=salon -t -A -c "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
else
  CUSTOMER_NAME=$(psql --username=freecodecamp --dbname=salon -t -A -c "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID;")
fi

echo "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

psql --username=freecodecamp --dbname=salon -c "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');" > /dev/null

echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
