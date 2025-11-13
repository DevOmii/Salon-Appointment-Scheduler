#!/bin/bash

# Salon Appointment Scheduler

# Display header
echo "~~~~~ MY SALON ~~~~~"
echo ""
echo "Welcome to My Salon, how can I help you?"
echo ""

# Main loop for service selection
while true; do
  # Display available services
  psql --username=freecodecamp --dbname=salon -t -A -c "SELECT service_id, name FROM services ORDER BY service_id;" | sed 's/|/) /'
  
  # Read service selection
  read SERVICE_ID_SELECTED
  
  # Validate service selection
  SERVICE_NAME=$(psql --username=freecodecamp --dbname=salon -t -A -c "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
  
  if [ -z "$SERVICE_NAME" ]; then
    echo "I could not find that service. What would you like today?"
    echo ""
  else
    # Service is valid, break the loop
    break
  fi
done

# Read phone number
# CAMBIO AQUÍ: de 'read -p' a 'echo' + 'read'
echo "What's your phone number?"
read CUSTOMER_PHONE

# Check if customer exists
CUSTOMER_ID=$(psql --username=freecodecamp --dbname=salon -t -A -c "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")

if [ -z "$CUSTOMER_ID" ]; then
  # Customer doesn't exist, ask for name and add to database
  # CAMBIO AQUÍ: de 'read -p' a 'echo' + 'read'
  echo "I don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  
  # Add customer to database
  psql --username=freecodecamp --dbname=salon -c "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME');" > /dev/null
  
  # Get the customer_id of the newly created customer
  CUSTOMER_ID=$(psql --username=freecodecamp --dbname=salon -t -A -c "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
else
  # Customer exists, retrieve their name for use in prompts
  CUSTOMER_NAME=$(psql --username=freecodecamp --dbname=salon -t -A -c "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID;")
fi

# Read appointment time
# CAMBIO AQUÍ: de 'read -p' a 'echo' + 'read'
echo "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

# Add appointment to database
psql --username=freecodecamp --dbname=salon -c "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');" > /dev/null

# Display confirmation message
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."