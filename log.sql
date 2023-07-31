-- Keep a log of any SQL queries you execute as you solve the mystery.

-- Explore tables in database
.table

-- Explore crime_scene_reports table
.schema crime_scene_reports

-- Find crime description of CS50 duck theft
SELECT * FROM crime_scene_reports
WHERE month = 7 AND day = 28
AND street = 'Humphrey Street';
-- Theft took place at 10:15am at the Humphrey Street bakery

-- Explore interviews
.schema interviews

-- Find transcripts of interviews of witnesses
SELECT * FROM interviews
WHERE month = 7 AND day = 28;
-- Witnesses:
-- Ruth - Thief left in car from Bakery parking lot within 10 minutes of theft. Look for cars in that time-frame
-- Eugene - Earlier that morning before Eugene went to Emma's bakery, thief withdrawed cash from ATM on Leggett Street
-- Raymond - As the thief was leaving the bakery, they spoke to accomplice over phone for less than a minute, asking to buy a ticket of the earliest flight out of Fiftyville the next day

-- Find destination city of the first flight out of Fiftyville on 29th of July(next day of theft)
SELECT city FROM airports
WHERE id = (
    SELECT destination_airport_id FROM flights, airports
    WHERE flights.origin_airport_id = airports.id
    AND flights.month = 7 AND flights.day = 29
    AND airports.city = 'Fiftyville'
    ORDER BY flights.hour, flights.minute
    LIMIT 1
);
-- Thief escaped to New York City

-- Find suspects who qualify for the following:

-- Withdrawed cash from an ATM on Leggett Street on 28th of July.
-- Departed from bakery within 10 minutes of the theft.
-- Called the accomplice after theft and spoke for less than a minute.
-- Boarded the first flight out of Fiftyville the next day.
SELECT * FROM people
-- suspect on the basis of ATM transaction
WHERE id IN (
    SELECT person_id FROM bank_accounts, atm_transactions
    WHERE bank_accounts.account_number = atm_transactions.account_number
    AND atm_transactions.month = 7 AND atm_transactions.day = 28
    AND atm_transactions.atm_location = "Leggett Street"
    AND atm_transactions.transaction_type = 'withdraw'
)
-- suspect on the basis of boarding the first flight
AND passport_number IN (
    SELECT passport_number FROM passengers
    WHERE flight_id = (
        SELECT flights.id FROM flights, airports
        WHERE flights.origin_airport_id = airports.id
        AND flights.month = 7 AND flights.day = 29
        AND airports.city = 'Fiftyville'
        ORDER BY flights.hour, flights.minute
        LIMIT 1
    )
)
-- suspect for departing from the bakery in a car within 10 minutes of theft
AND license_plate IN (
    SELECT license_plate FROM bakery_security_logs
    WHERE month = 7 AND day = 28
    AND hour = 10
    AND minute <= 25
    AND minute >= 15
)
-- suspect for calling the accomplice
AND phone_number IN (
    SELECT caller FROM phone_calls
    WHERE month = 7 AND day = 28
    AND duration < 60
);
-- Suspects:
-- +--------+--------+----------------+-----------------+---------------+
-- |   id   |  name  |  phone_number  | passport_number | license_plate |
-- +--------+--------+----------------+-----------------+---------------+
-- | 686048 | Bruce  | (367) 555-5533 | 5773159633      | 94KL13X       |
-- +--------+--------+----------------+-----------------+---------------+
-- So, the thief is Bruce.

-- Find the accomplice whom Bruce contacted after theft and asked to book the flight
SELECT * FROM people
WHERE phone_number = (
    SELECT receiver FROM phone_calls
    WHERE month = 7 AND day = 28
    AND duration < 60 AND caller = '(367) 555-5533'
);
-- +--------+-------+----------------+-----------------+---------------+
-- |   id   | name  |  phone_number  | passport_number | license_plate |
-- +--------+-------+----------------+-----------------+---------------+
-- | 864400 | Robin | (375) 555-8161 | NULL            | 4V16VO0       |
-- +--------+-------+----------------+-----------------+---------------+
-- The accomplice is Robin.
