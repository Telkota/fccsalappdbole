#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo -e "Welcome to My Salon, how can I help you?\n"
  fi

  #Fetch available services to display
  AVAILABLE_SERVICES=$($PSQL "select * from services")

  #Show welcome message and services
  echo "$AVAILABLE_SERVICES" | while read ID BAR NAME
  do
  echo "$ID) $NAME"
  done

  MAKE_APPOINTMENT
}

MAKE_APPOINTMENT () {

  #Get input from user
  read SERVICE_ID_SELECTED

  #check to see if the input is valid
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    #if the input is not a number then show the main menu again
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    #Check if the number corresponds to a service name
    SERVICE_NAME=$($PSQL "select name from services where service_id = $SERVICE_ID_SELECTED")
    
    #If no service name is found, return the user to the main menu
    if [[ -z $SERVICE_NAME ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
    fi
  fi
  
  #get the customer's phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  #Check if customer is already in the database
  CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")

  #if customer is not found
  if [[ -z $CUSTOMER_ID ]]
  then
    #get customer name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    #insert new customer into database
    INSERT_CUSTOMER_RESULT=$($PSQL "insert into customers(name, phone) values('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    #get customer ID for appointment later
    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
  else
    CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")
  fi


  #get the time from the customer
  echo -e "\nWhat time would you like your$SERVICE_NAME, $CUSTOMER_NAME"
  read SERVICE_TIME

  #try to insert results into database
  INSERT_APPOINTMENT_RESULT=$($PSQL "insert into appointments(time, customer_id, service_id) values('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")
  
  #check if it succeeded
  if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]
  then
    #print out the result
    echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  else
    MAIN_MENU "That's not a valid time input - Returning you to main menu"
  fi
  
  exit 0
}

MAIN_MENU
