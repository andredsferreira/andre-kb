#!/bin/bash

# Define variables

username="Alice"
count=3
file_path="./example.txt"
names=("Andrew" "Josh" "Kevin")

# Function to greet the user

greet() {
  echo "Hello, $1!"
}

# Call the function

greet "$username"

# Check if a file exists

if [[ -f "$file_path" ]]; then
  echo "File '$file_path' exists."
else
  echo "File '$file_path' does not exist."
fi

# For loop over a list

echo "Looping over a list:"
for item in apple banana cherry; do
  echo "- $item"
done

echo "Looping over a defined list:"
for name in "${names[@]}"; do
  echo "My name is $name"
done

# While loop to count down

echo "Countdown:"
while [[ $count -gt 0 ]]; do
  echo "$count..."
  count=$((count - 1))  # decrement count
done
echo "Done!"

# Read user input

read -p "Enter your favorite color: " color

if [[ "$color" == "blue" ]]; then
  echo "That's a calm choice!"
elif [[ "$color" == "red" ]]; then
  echo "That's a bold choice!"
else
  echo "Nice, $color is a great color!"
fi

# Check if a variable is set

if [[ -n "${username+x}" ]]; then
  echo "'username' is set to '$username'."
else
  echo "'username' is not set."
fi
