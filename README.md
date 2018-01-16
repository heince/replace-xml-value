# replace-xml-value
replace xml attribute or child node value recursively

This script is created to clean xml configuration files by replacing it value, e.g "reseting user / password / ipaddress, etc".

Configuration is located in etc/cleansing.conf

if it's an element with attribute, for example <user name="superman" age="100"/> , you use single space to separate node with attribute name :

user name=reseted

user age=xxx

