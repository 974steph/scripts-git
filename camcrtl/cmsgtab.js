﻿
var gStatus = new Object();
gStatus.OK = "OK";
gStatus.JE0101 = "Complete the \"NTP server address\" field.";
gStatus.JE0102 = "Complete the \"Port number\" field.";
gStatus.JE0103 = "Complete the \"Multicast address\" field.";
gStatus.JE0104 = "Complete the \"Multicast TTL\" field.";
gStatus.JE0105 = "Complete the \"File name\" field.";
gStatus.JE0106 = "Complete the \"Pulse width\" field.";
gStatus.JE0107 = "Complete the \"Mail address\" field.";
gStatus.JE0108 = "Complete the \"User name\" field.";
gStatus.JE0109 = "Complete the \"Password\" field.";
gStatus.JE0110 = "Complete the \"IP address\" field.";
gStatus.JE0111 = "Complete the \"SMTP server address\" field.";
gStatus.JE0112 = "Complete the \"POP server address\" field.";
gStatus.JE0113 = "Complete the \"FTP server address\" field.";
gStatus.JE0114 = "Complete the \"Subnet mask\" field.";
gStatus.JE0115 = "Complete the \"Password\" field.";
gStatus.JE0116 = "Complete the \"Host name\" field.";
gStatus.JE0117 = "No file has been selected. Please select the file.";
gStatus.JE0118 = "Password entered in the \"Retype password\" field is incorrect.";
gStatus.JE0119 = "Complete the \"Default gateway\" field.";
gStatus.JE0122 = "Complete the \"Pulse width\" field.";
gStatus.JE0123 = "Complete the \"Mail subject\" field.";
gStatus.JE0124 = "Complete the \"Destination IP address\" field.";
gStatus.JE0125 = "Complete the \"Destination address\" field.";
gStatus.JE0201 = "Entered information is incorrect. Enter again.";
gStatus.JE0202 = "Entered information is incorrect. Enter only numbers.";
gStatus.JE0203 = "Entered information is incorrect. Enter only even numbers.";
gStatus.JE0204 = "Space and 2 byte code cannot be used for the preservation directory of the firmware on PC.";
gStatus.JE0205 = "Unavailable value";
gStatus.JE0206 = "The same address cannot be assigned for \"Transmission 1\" and \"Transmission 2\".";
gStatus.JE0207 = "Space and 2 byte code cannot be used for the preservation directory of the file on PC.";
gStatus.JE0301 = "Port 80 is reserved for HTTP.";
gStatus.JE0302 = "Ports 20/21 are reserved for FTP.";
gStatus.JE0303 = "Port 25 is reserved for SMTP.";
gStatus.JE0304 = "Ports 42/53 are reserved for DNS.";
gStatus.JE0305 = "Port 69 is reserved for FTP.";
gStatus.JE0306 = "Port 23 is reserved for telnet.";
gStatus.JE0307 = "Ports 110/995 are reserved for POP3.";
gStatus.JE0308 = "Ports 161/162 are reserved for SNMP.";
gStatus.JE0309 = "Port 20 is reserved for FTP.";
gStatus.JE0310 = "Port 123 is reserved for NTP.";
gStatus.JE0311 = "Ports 67/68 are reserved for DHCP.";
gStatus.JE0313 = "Ports 10669/10670 are reserved for BOOTP.";
gStatus.JE0314 = "Invalid IP address. Enter again.";
gStatus.JE0315 = "This port is used.";
gStatus.JE0316 = "Port number 443 is reserved (HTTPS).";
gStatus.JE0401 = "Since \"On\" is set for \"MPEG-4 transmission\", \"15fps\" is applied to \"Refresh interval (JPEG)\".";
gStatus.JE0402 = "Since \"On\" is set for \"MPEG-4 transmission\", \"5fps\" is applied to \"Refresh interval (JPEG)\".";
gStatus.JE0403 = "The set value for \"Bandwidth control(bit rate)\" is lower than the value of \"Max bit rate (per client)\".";
gStatus.JE0406 = "Since the set value for \"Bandwidth control(bit rate)\" is lower than the value of \"Max bit rate (per client)\", \naudio may not be output.";
gStatus.JE0410 = "Since \"On\" is set for \"MPEG-4 transmission\", \"10fps\" is applied to \"Refresh interval (JPEG)\".";
gStatus.JE0411 = "Since image quality set for\"Image quality upon alarm detection\" is lower than the one set for  \"Image quality 1\" of \"JPEG\", image quality set for \"Image quality 1\" of \"JPEG\"  will be applied.";
gStatus.JE0412 = "Since \"On\" is set for \"MPEG-4 transmission\", \"1fps\" is applied to \"Refresh interval (JPEG)\".";
gStatus.JE0413 = "Simultaneous video output may become impossible since the value set for \"Bandwidth control(bit rate)\" is lower that the value set for \"Max bit rate (per client) for transmission 1, 2\".";
gStatus.JE0414 = "Since \"On\" is set for \"H.264 transmission\", \"15fps\" is applied to \"Refresh interval (JPEG)\".";
gStatus.JE0415 = "Since \"On\" is set for \"H.264 transmission\", \"10fps\" is applied to \"Refresh interval (JPEG)\".";
gStatus.JE0416 = "Since \"On\" is set for \"H.264 transmission\", \"1fps\" is applied to \"Refresh interval (JPEG)\".";
gStatus.JE0417 = "\"3 mega pixel\" is selected for \"Image capture mode\".";
gStatus.JE0418 = "The parameter \"5fps\" will automatically be set for \"Refresh interval\" of JPEG images.";
gStatus.JE0419 = "The parameter \"10fps\" will automatically be set for \"Refresh interval\" of JPEG images.";
gStatus.JE0420 = "The parameter \"15fps\" will automatically be set for \"Refresh interval\" of JPEG images.";
gStatus.JE0421 = "The set value for \"Max bit rate (per client)\" is lower than \"Minimum bit rate(per client)\".";
gStatus.JE0422 = "The CRT key will be generated.\nIn updating the CRT key, the CA Certificate corresponds to the current CRT key will become unavailable.\nContinue?";
gStatus.JE0423 = "The previous CRT key will be loaded.\nPlease generate Self-signed Certificate or install the CA Certificate corresponds to the CRT key.\nContinue?";
gStatus.JE0424 = "Since \"On\" is set for \"H.264 transmission\", \"5fps\" is applied to \"Refresh interval (JPEG)\".";
gStatus.JE0501 = "Registration of the position failed. Please try to register the position again.";
gStatus.JE0502 = "Deletion of the position failed. Please try to delete the position again.";
gStatus.JE0503 = "Failed to download the images. \nPlease check if the SD memory card is inserted correctly.";
gStatus.JE0504 = "Failed to download the images. ";
gStatus.JE0506 = "Permission of operation revoked.\nReturn to the \"Live\" page.";
gStatus.JE0507 = "Failed to download the images.";
gStatus.JE0508 = "Playback will stop and return to the \"Live\" page.";
gStatus.JE0509 = "The file doesn't exist.";
gStatus.JE0601 = "Camera is busy.  \nPlease wait around 30 seconds, and  then click the [OK] button.";
gStatus.JE0602 = "Camera is busy.  \nPlease wait around 30 seconds, and  then click the [OK] button.";
gStatus.JE0901 = "18 users have already been registered. (Reached the maximum number of user registration.)";
gStatus.JE0902 = "It is necessary to register at least 1 administrator.";
gStatus.JE0903 = "18 hosts have already been registered. (Reached the maximum number of host registration.)";
gStatus.JE0904 = "Before deleting \"IP address\", click the [Set] button after selecting \"Off\" for \"Host auth.\".";
gStatus.JE0905 = "After registering \"IP address\", click the [Set] button after selecting \"On\" for \"Host auth.\".";
gStatus.JE0906 = "Mail body can contain up to 200 characters.";
gStatus.JE0907 = "It is necessary to reboot the camera to change the setting. \nWhen \"Not use\" is set for \"SD memory card\", System log and Alarm log will be deleted.\nProceed?";
gStatus.JE0908 = "Start formatting after setting \"Off\" for \"FTP periodic image transmission\".";
gStatus.JE0909 = "The network setting will be changed.\nWhen \"Not use\" is set for \"SD memory card\", System log and Alarm log will be deleted.\nProceed?";
gStatus.JE0910 = "The specified multicast port is already in use. Please change the port number.";
gStatus.JE0911 = "When the [OK] button is clicked, data is initialized with upgrade. \nInitialization of the above setup data is available only for the application.\nWhen \"Not use\" is set for \"SD memory card\", System log and Alarm log will be deleted.\nProceed?";
gStatus.JE0912 = "The FTP server address is set to \"localhost\". \nThe FTP periodic image cannot be set to \"On\".";
gStatus.JE0913 = "The FTP periodic image is set to \"On\".\nThe FTP server address cannot be set to \"localhost\".";
gStatus.JE0914 = "Connection has been disconnected. Please confirm connection.";
gStatus.JE0915 = "Camera";
gStatus.JE0916 = "After installing the CA Certificate, reboot the camera. \nProceed?";
gStatus.JE0920 = "The \"FTP periodic image transmission\" setting and the \"Alarm image FTP transmission\" setting will be \"Off\".";
gStatus.JE0921 = "The specified unicast port1(Image) is already in use. Please change the port number.";
gStatus.JE0922 = "The specified unicast port2(Audio) is already in use. Please change the port number.";
gStatus.JE0923 = "The specified alarm status port is already in use. Please change the port number.";
gStatus.JE0924 = "\"User name\" and \"Password\" remain as the default. \nPlease change them.";
gStatus.JE0925 = "The viewer software is not installed.\nInstallation of the viewer software will start.";
gStatus.JE0927 = "It is impossible to apply IP address v4 and v6 to the primary and secondary server independently.";
gStatus.JE0928 = "Since \"Off \" is selected for  \"MPEG-4 transmission \", the settings will not be applied. Proceed?";
gStatus.JE0929 = "Since \"Off \" is selected for  \"H.264 transmission \", the settings will not be applied. Proceed?";
gStatus.JE0930 = "The window associated with the clicked button is going to be opened.\nWhen the settings on the currently displayed window have been edited, they will not be saved unless the [Set] button is clicked.\nProceed to open the associated window?";
gStatus.JE0931 = "The \"Audio transmission/reception\" setting will automatically be set to \"Off\".\nThe \"Transmission type\" setting will automatically be set to \"Unicast port (AUTO)\".";
gStatus.JE0932 = "The \"Audio transmission/reception\" setting will automatically be set to \"Mic input\".\nThe \"Transmission type\" setting will automatically be set to \"Unicast port (AUTO)\".";
gStatus.JE0933 = "The \"Transmission type\" setting will automatically be set to \"Unicast port (AUTO)\".";
gStatus.JE0934 = "The \"Audio transmission/reception\" setting will automatically be set to \"Off\".";
gStatus.JE0935 = "The \"Audio transmission/reception\" setting will automatically be set to \"Mic input\".";
gStatus.JE0936 = "The \"Internet mode\" setting will automatically be set to \"Off\".";
gStatus.JE0937 = "It is necessary to reboot the camera to change the setting.  \nWhen \"Not use\" is set for \"SD memory card\", System log and Alarm log will be deleted.\nProceed? \nWhen selecting \"3 mega pixel\", the following settings will be affected. \n- \"Super Dynamic\" setting \n- Frame rate: Maximum value becomes 15fps ";
gStatus.JE0938 = "It is necessary to reboot the camera to change the setting. \nWhen \"Not use\" is set for \"SD memory card\", System log and Alarm log will be deleted.\nProceed?";
gStatus.JE0939 = "Cannot change the image capture mode. \nCheck if the following setting has been changed or not. \n- \"Image capture size\" of JPEG: 2048x1536";
gStatus.JE0940 = "Cannot change the image capture mode. \nCheck if the following settings have been changed or not. \n- \"Image capture size\" of JPEG: QVGA \n- \"Image capture size\" of \"Rec. on SD\": QVGA \n- \"Image capture size\" of \"Alarm image\": QVGA \n- \"Image capture size\" of \"FTP periodic image transmission\": QVGA \n- \"Stream type\" of \"Priority stream\": JPEG \n";
gStatus.JE0941 = "\"3 mega pixel\" is selected for \"Image capture mode\". The setting will not be applied. Proceed?";
gStatus.JE0942 = "\"Frame rate\" will become \"15fps\" at a maximum since \"3 mega pixel\" is selected for \"Image capture mode\".";
gStatus.JE0943 = "Proceed to format the SD memory card (recommend)?\nWhen the [OK] button is clicked, the SD memory card will be formatted and all data deleted. \nIt is impossible to access the SD memory card during the format process.";
gStatus.JE0944 = "Actual refresh interval (JPEG) may be lower than the specified value depending on the value set for \"Image capture size\".";
gStatus.JE0945 = "Others' operations will be canceled. \nProceed?";
gStatus.JE0946 = "Designed schedule is overlapping.Proceed?";
gStatus.JE0947 = "Initialization of the above setup data is available only for the application. \nWhen \"Not use\" is set for \"SD memory card\", System log and Alarm log will be deleted.\nProceed?";
gStatus.JE0948 = "When the [OK] button is clicked, data is initialized with upgrade. Proceed?";
gStatus.JE1900 = "The \"Video encoding format\" setting will automatically be set to \"H.264\".";
gStatus.JE1901 = "The \"Recording format\" setting will automatically be set to \"JPEG\".";
gStatus.JE0949 = "When \"H.264 recording\" is selected for \"Schedule mode\" on the [Schedule] tab, the schedule will be deleted.\nProceed?";
gStatus.JE0950 = "To activate the H.264 or MPEG-4 transmission, \nselect \"On\" for \"Internet mode (over HTTP)\" on the [JPEG/H.264] (or [JPEG/MPEG-4]) tab of the \"Image/Audio\" page.";
gStatus.JE0951 = "To activate the H.264 transmission, \nselect \"On\" for \"Internet mode (over HTTP)\" on the [JPEG/H.264] tab of the \"Image\" page.";
gStatus.JE0952 = "The network setting will be changed.\nSystem log will be deleted.\nProceed?";
gStatus.JE0953 = "It is necessary to reboot the camera to change the setting. \nSystem log will be deleted.\nProceed?";
gStatus.JE0954 = "When the [OK] button is clicked, data is initialized with upgrade. \nSystem log will be deleted.\nProceed?";
gStatus.JE0955 = "Select \"1s\" or \"2s\" for the notification interval when selecting \"Detection info.(Original)\" for \"Notification data\". ";
gStatus.JE0956 = "\"16:9\" is selected for \"Aspect ratio\".\nWhen setting the mask area for the back light compensation (BLC) function, it is necessary to configure the setting after selecting \"4:3\" for \"Aspect ratio\".\nThe mask area set at \"4:3\" is maintained after the setting of \"Aspect ratio\" was changed to \"16:9\".";
gStatus.JE0957 = "When \"-10°\" or \"-15°\" is selected for \"Tilt Angle\", tilt-flip function works near tilting angle 90°.";
gStatus.JE0958 = "When \"Authentication\" setting is changed, close the browser, and then access the camera again.";
gStatus.JE0959 = "System log will be deleted.\nProceed?";
gStatus.JE0960 = "It is necessary to reboot the camera to change the setting. \nProceed?";
gStatus.JE0961 = "「H.264配信/録画」が動作中の場合、JPEG画像の「画像更新速度」は「5fps」で動作します。";
gStatus.JE0962 = "Since \"On\" is selected for \"Host auth.\", it is necessary to register at least 1 administrator.";