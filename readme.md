# Laptop Battery Power Management App for Linux via TLP

## Requirements
- **TLP v. 1.6.1**

## Usage

1. Run the following command in the root folder to build the program:
   ```make```

2. To switch between configurations, run the program:
    ```make run```
⚠ This requires sudo privileges.

3. Enter a command to manage profiles:
    To switch between configurations, use:
    ```cycle <profile_key>```
For example, the command:
    ```cycle <main>```
will attempt to switch to the configuration with the key ```main```.

To print a list of profiles stored in data/current_profiles.txt, if the corresponding file was in /etc/tlp.d/, run:
    ```print_active_profiles```
