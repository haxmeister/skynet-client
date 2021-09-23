# skynet-client
Vendetta Online client for the Skynet server.

# USAGE
Install the files in the vendetta plugins directory according to your operating systems location.

On my Linux system that would be ```~/.vendetta/plugins/skynet ```
Where "skynet" folder would be created to contain the files in this repository.
I simplify this by just using ``` git clone``` in the plugins folder which will make a folder named "skynet-client".. the name of that folder is irrelevant. This facilitates an easy upgrade when a new version is released and the game ignores the .git folders that git creates. I recommend this for upgrade simplicity to those who know how to use git on their systems.

## COMMANDS

```
/skynet connect
```
Connect to the skynet server. The plugin is designed to log you in automatically when you connect to the server using the information you entered using the config command. If your client does not send this information, you may still be allowed to connect. However you will be recognized only as an unknown user and will not have permissions to do or see any of the functionality provided by the server.

```
/skynet disconnect
```
Disconnect from the server

```
/skynet config
```
Opens a user interface where you can enter your username and password and other preferences

```
/skynet listpayment
```
*permissions required for use*
Opens a user interface showing all pilots who have purchased a warranty and how much time they have left. Your ability to view this list is dependent upon whether you have been granted permissions or not.

```
/skynet listkos
```
*permissions required for use*
Opens a user interface that shows all pilots who have KOS status.

```
/skynet listallies
```
*permissions required for use*
Opens a user interface that shows all pilots who have ALLY status.

```
/skynet list
```
*permissions required for use*
Opens a user interface that shows all pilots in the system and all their statuses.

```
/skynet addpayment [name] [time]
```
*permissions required for use*
Adds a pilot to the system as having a warranty. The warranty will have a timer which starts at the moment the command is submitted. The [time] parameter for this command can be in days, hours or seconds. This is accomplished by appending a corresponding single letter to the end of the [time] parameter. For instance ```/skynet addpayment someuser 24d``` would give "someuser" 24 days of warranty time. Use "h" for hours. No letter will translate to seconds. Put [name] in quotes to accommodate names that contain spaces or other silly characters.

```
/skynet removepayment [name]
```
*permissions required for use*
Removes all warranty time for the username provided

```
/skynet addkos [name] [length] [notes]
```
*permissions required for use*
Adds a pilot to the KOS list. This command allows optionally some text in quotations as notes that will appear when users look at the list. The parameter [length] functions the same as the addpayment command with a number and a suffix letter d or h for days or hours.

```
/skynet removekos [name]
```
*permissions required for use*
Remove they pilot from the KOS list. Where [name] should be the pilots in game name. Wrap this name in quotes to avoid problems with spaces and other characters.

``` 
/skynet addally [name]
```
*permissions required for use*
Add a pilot to the ALLY list. Where [name] should be the pilots in game name. Wrap this name in quotes to avoid problems with spaces or other characters.

```
/skynet removeally [name]
```
*permissions required for use*
Remove they pilot from the ALLY list. Where [name] should be the pilots in game name. Wrap this name in quotes to avoid problems with spaces and other char

```
/skynet adduser
```
*permissions required for use*
Opens a user inteface window that allows you to create a username, password and set permissions for a new user of skynet. Note that this interface will overwrite any existing user by the same name. This may be useful for changing a user's access permissions.

```
/skynet removeuser [name]
```
*permissions required for use*
Removes a user from skynet. Where [name] should be wrapped in quotes to avoid problems with spaces and other char

```
/skynet clearspots
```
Removes persistent spots shown on the HUD window. Due to the nature of the LUA interface, some spots may remain indefinitely until cleared.

```
/skynet help
```
Should show this list of available commands (to be improved upon)
