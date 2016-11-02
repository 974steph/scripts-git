
function chknet_isIpBlank(arIP1, arIP2, arIP3, arIP4) {
	for (iIndex = 1; iIndex <= 4; iIndex++) {
		var sOctet = eval("arIP" + iIndex);
		if (sOctet.length == 0) {
			giErrNum = iIndex;
			return true;
		}
	}
	return false;
}

function chknet_IsIpDigit(arIP1, arIP2, arIP3, arIP4) {
	for (var iIndex = 1; iIndex <= 4; iIndex++) {
		if (!capi_isDigit(eval("arIP" + iIndex))) {
			objErrCode = cmsg_show("JE0202");
			giErrNum = iIndex;
			return false;
		}
	}
	return true;
}

function chknet_CheckRange(arIP1, arIP2, arIP3, arIP4) {
	var arIP = new Array();
	var iIndex;
	for (iIndex = 1; iIndex <= 4; iIndex++) {
		if (!capi_isDigit(eval("arIP" + iIndex))) {
			objErrCode = cmsg_show("JE0202");
			giErrNum = iIndex;
			return false;
		}
		arIP[iIndex] = parseInt(eval("arIP" + iIndex));
	}
	for (iIndex = 1; iIndex <= 4; iIndex++) {
		if ((arIP[iIndex] < 0) || (arIP[iIndex] > 255)) {
			objErrCode = cmsg_show("JE0201");
			giErrNum = iIndex;
			return false;
		}
	}
	if ((arIP[1] == 0) || ((arIP[1] == 127) && (arIP[2] == 0) && (arIP[3] == 0) && (arIP[4] == 1))) {
		objErrCode = cmsg_show("JE0314");
		giErrNum = 1;
		return false;
	}
	if ((arIP[4] == 0) || (arIP[4] == 255)) {
		objErrCode = cmsg_show("JE0314");
		giErrNum = 4;
		return false;
	}
	if (arIP[1] >= 224) {
		objErrCode = cmsg_show("JE0314");
		giErrNum = 1;
		return false;
	}
	return true;
}

function chknet_portNo(sPort, strSevrer, ghttpsmode) {
	if (sPort.length == 0) {
		objErrCode = cmsg_show("JE0102");
		return false;
	}
	if (!capi_isDigit(sPort)) {
		objErrCode = cmsg_show("JE0202");
		return false;
	}
	var iWork = parseInt(sPort);
	if ((iWork < 1) || (65535 < iWork)) {
		objErrCode = cmsg_show("JE0201");
		return false;
	}
	if (!chknet_portReservedNo(sPort, strSevrer, ghttpsmode)) {
		return false;
	}
	return true;
}

function chknet_portReservedNo(str, strSevrer, ghttpsmode) {
	var port = parseInt(str);
	if ((strSevrer != "HTTP") && (strSevrer != "HTTPS")) {
		if (port == 80) {
			objErrCode = cmsg_show("JE0301");
			return false;
		}
	}
	if (strSevrer != "FTP") {
		if (port == 20 || port == 21) {
			objErrCode = cmsg_show("JE0302");
			return false;
		}
	}
	if (strSevrer != "SMTP") {
		if (port == 25) {
			objErrCode = cmsg_show("JE0303");
			return false;
		}
	}
	if (strSevrer != "DNS") {
		if (port == 42 || port == 53) {
			objErrCode = cmsg_show("JE0304");
			return false;
		}
	}
	if (strSevrer != "tFTP") {
		if (port == 69) {
			objErrCode = cmsg_show("JE0305");
			return false;
		}
	}
	if (strSevrer != "Telnet") {
		if (port == 23) {
			objErrCode = cmsg_show("JE0306");
			return false;
		}
	}
	if (strSevrer != "POP3") {
		if (port == 110 || port == 995) {
			objErrCode = cmsg_show("JE0307");
			return false;
		}
	}
	if (strSevrer != "SNMP") {
		if (port == 161 || port == 162) {
			objErrCode = cmsg_show("JE0308");
			return false;
		}
		if ((strSevrer == "HTTP" || strSevrer == "CMD" || strSevrer == "HTTPS") && (port == 61000)) {
			objErrCode = cmsg_show("JE0315");
			return false;
		}
	}
	if (strSevrer != "NTP") {
		if (port == 123) {
			objErrCode = cmsg_show("JE0310");
			return false;
		}
	}
	if (strSevrer != "BOOTP/DHCP") {
		if (port == 67 || port == 68) {
			objErrCode = cmsg_show("JE0311");
			return false;
		}
	}
	if (strSevrer != "BOOTP") {
		if (port == 10669 || port == 10670) {
			objErrCode = cmsg_show("JE0313");
			return false;
		}
	}
	if (ghttpsmode == 1) {
		if (strSevrer != "HTTPS") {
			if (port == 443) {
				objErrCode = cmsg_show("JE0316");
				return false;
			}
		}
	}
	return true;
}

function chknet_ServerAddress(str) {
	if (chknet_ipaddr_familly(str) == "IPv6") {
		return chknet_IsValidIpv6(str);
	} else {
		var strSymbol = "._-";
		if (!capi_isAlphaNumSymbol(str, strSymbol)) {
			objErrCode = cmsg_show("JE0201");
			return false;
		}
		if (!chknet_label(str)) {
			objErrCode = cmsg_show("JE0201");
			return false;
		}
		var arIP = new Array();
		var prepos = 0;
		var index = 0;
		var deli = ".";
		var deli_length = deli.length;
		while ((pos = str.indexOf(deli, prepos)) != -1) {
			arIP[index++] = str.substring(prepos, pos);
			prepos = pos + deli_length;
		}
		arIP[index] = str.substring(prepos);
		if (capi_isNumSymbol(str, strSymbol)) {
			if (index != 3) {
				objErrCode = cmsg_show("JE0201");
				return false;
			} else {
				if (!chknet_CheckRange(arIP[0], arIP[1], arIP[2], arIP[3])) {
					return false;
				}
			}
		}
	}
	return true;
}

function chknet_IsValidIpAddress(sAddr) {
	if (chknet_ipaddr_familly(sAddr) == "IPv6") {
		return chknet_IsValidIpv6(sAddr);
	} else {
		var iIP = new Array();
		var sSymbol = ".";
		if (capi_CharCounter(sAddr, sSymbol) != 3) {
			objErrCode = cmsg_show("JE0201");
			return false;
		}
		for (var iIndex = 0; iIndex < 4; iIndex++) {
			iIP[iIndex] = sAddr.split(sSymbol)[iIndex];
			if (!capi_isDigit(iIP[iIndex])) {
				objErrCode = cmsg_show("JE0201");
				return false;
			}
			if (iIP[iIndex].length == 0) {
				objErrCode = cmsg_show("JE0201");
				return false;
			}
		}
		return chknet_CheckRange(iIP[0], iIP[1], iIP[2], iIP[3]);
	}
}

function chknet_label(str) {
	var cnt = 0;
	var next = 0;
	var label = 0;
	while (next != -1) {
		next = str.indexOf(".", cnt);
		if (cnt == 0 && next == -1) {
			label = str.length;
		} else if (cnt != 0 && next == -1) {
			label = str.length - cnt;
		} else {
			label = next - cnt;
		}
		if ((label < 1) || (label > 63)) {
			return false;
		} else {
			cnt = next + 1;
		}
	}
	return true;
}

function chknet_IsValidIpv6(sAddr) {
	var iChar = capi_CharCounter(sAddr, ":")
	if ((sAddr.length > 45) || (iChar > 7)) {
		objErrCode = cmsg_show("JE0201");
		return false;
	}
	for (var iIndex = 0; iIndex < iChar; iIndex++) {
		if (sAddr.split(":")[iIndex].length > 4) {
			objErrCode = cmsg_show("JE0201");
			return false;
		}
	}
	var sLaOct = sAddr.split(":")[iChar];
	if (capi_CharCounter(sLaOct, ".") == 3) {
		var iIP = new Array();
		for (var iIndex = 0; iIndex < 4; iIndex++) {
			iIP[iIndex] = sLaOct.split(".")[iIndex];
			if (!capi_isDigit(iIP[iIndex])) {
				objErrCode = cmsg_show("JE0201");
				return false;
			}
			if (iIP[iIndex].length == 0) {
				objErrCode = cmsg_show("JE0201");
				return false;
			}
		}
	} else {
		if (sLaOct.length > 4) {
			objErrCode = cmsg_show("JE0201");
			return false;
		}
	}
	var iPosi = sAddr.indexOf("::");
	if (iPosi != -1) {
		if (sAddr.substring(iPosi + 2, iPosi + 3) == ":") {
			objErrCode = cmsg_show("JE0201");
			return false;
		}
		if (sAddr.substring(iPosi + 2).indexOf("::") != -1) {
			objErrCode = cmsg_show("JE0201");
			return false;
		}
	}
	var sStOct = sAddr.substring(0, 2).toLowerCase();
	if (sStOct == "ff") {
		objErrCode = cmsg_show("JE0201");
		return false;
	}
	var strSymbol = new Array("abcdef:", "abcdef:.");
	if (capi_isNumSymbol(sAddr, strSymbol[0])) {
		return chknet_IsValidIpv6Address(sAddr);
	} else if (capi_isNumSymbol(sAddr, strSymbol[1])) {
		return chknet_IsValidIpv6Comp(sAddr);
	} else {
		objErrCode = cmsg_show("JE0201");
		return false;
	}
}

function chknet_IsValidIpv6Address(sAddr) {
	var iErCnt = 0;
	var iLen = 8;
	var sv6Addr = "";
	var iIPv6 = new Array();
	var iNGv6 = new Array();
	iNGv6[0] = new Array(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
	iNGv6[1] = new Array(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
	sv6Addr = chknet_RepIpv6(sAddr, iLen);
	iIPv6 = chknet_RepIpv6_2(sv6Addr);
	if (iIPv6.length != iLen) {
		objErrCode = cmsg_show("JE0201");
		return false;
	}
	for (var j = 0; j < iNGv6.length; j++) {
		for (var k = 0; k < iNGv6[j].length; k++) {
			if (iIPv6[k] == iNGv6[j][k]) {
				iErCnt++;
			}
		}
		if (iErCnt == iLen) {
			objErrCode = cmsg_show("JE0201");
			return false;
		} else {
			iErCnt = 0;
		}
	}
	return true;
}

function chknet_IsValidIpv6Comp(sAddr) {
	var iErCnt = 0;
	var iLen = 6;
	var sv6Addr = "";
	var iIPv6 = new Array();
	var iCompv4 = new Array(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
	if (capi_CharCounter(sAddr, ".") != 3) {
		objErrCode = cmsg_show("JE0201");
		return false;
	}
	sv6Addr = sAddr.substring(0, sAddr.lastIndexOf(":") + 1);
	sv6Addr = chknet_RepIpv6(sv6Addr, iLen + 1);
	iIPv6 = chknet_RepIpv6_2(sv6Addr);
	if (iIPv6.length != iLen) {
		objErrCode = cmsg_show("JE0201");
		return false;
	}
	for (var k = 0; k < iLen; k++) {
		if (iIPv6[k] == iCompv4[k]) {
			iErCnt++;
		}
	}
	if (iErCnt != iLen) {
		objErrCode = cmsg_show("JE0201");
		return false;
	}
	return true;
}

function chknet_RepIpv6(sReAddr, iLen) {
	var iCnt = 0;
	var iPosi = 0;
	var sOct = "";
	if (sReAddr.charAt(0) == ":") {
		sReAddr = "0" + sReAddr;
	}
	iCnt = iLen - capi_CharCounter(sReAddr, ":");
	iPosi = sReAddr.indexOf("::");
	if (iPosi != -1) {
		for (var i = 0; i < iCnt; i++) {
			sOct = sOct + "0:";
		}
		sReAddr = sReAddr.substring(0, iPosi + 1) + sOct + sReAddr.substring(iPosi + 2);
	}
	if (sReAddr.charAt(sReAddr.length - 1) == ":") {
		if (iLen == 8) {
			sReAddr = sReAddr + "0";
		} else {
			sReAddr = sReAddr.substring(0, sReAddr.length - 1);
		}
	}
	return sReAddr;
}

function chknet_IsValidIpv6Only(sAddr) {
	if (chknet_ipaddr_familly(sAddr) == "IPv6") {
		return chknet_IsValidIpv6(sAddr);
	} else {
		objErrCode = cmsg_show("JE0201");
		return false;
	}
}

function chknet_CheckRange2(arIP1, arIP2, arIP3, arIP4) {
	var arIP = new Array();
	var iIndex;
	for (iIndex = 1; iIndex <= 4; iIndex++) {
		if (!capi_isDigit(eval("arIP" + iIndex))) {
			objErrCode = cmsg_show("JE0202");
			giErrNum = iIndex;
			return false;
		}
		arIP[iIndex] = parseInt(eval("arIP" + iIndex));
	}
	for (iIndex = 1; iIndex <= 4; iIndex++) {
		if ((arIP[iIndex] < 0) || (arIP[iIndex] > 255)) {
			objErrCode = cmsg_show("JE0201");
			giErrNum = iIndex;
			return false;
		}
	}
	return true;
}

function chknet_CheckIPv4Addr(ulIpAddr, ulSubnet) {
	if (!chknet_CheckClass(ulIpAddr)) {
		objErrCode = cmsg_show("JE0314");
		giErrNum = 1;
		return false;
	} else {
		if (0 == (ulIpAddr & ~ulSubnet)) {
			objErrCode = cmsg_show("JE0314");
			giErrNum = 1;
			return false;
		}
		if ((0xFFFFFFFF & ~ulSubnet) == (ulIpAddr & ~ulSubnet)) {
			objErrCode = cmsg_show("JE0314");
			giErrNum = 1;
			return false;
		}
	}
	return true;
}

function chknet_CheckIPv4Sub(ulSubnet) {
	var iCheck = 0;
	var ulMask = 0x00000001;
	if ((0xFFFFFFFF == ulSubnet) || ((0x80000000 & ulSubnet) == 0)) {
		objErrCode = cmsg_show("JE0314");
		giErrNum = 1;
		return false;
	}
	for (i = 0; i < 32; i++, ulMask <<= 1) {
		if (0 == iCheck) {
			if (0 != (ulSubnet & ulMask)) {
				iCheck = 1;
				if (2 > i) {
					objErrCode = cmsg_show("JE0314");
					giErrNum = 1;
					return false;
				}
			}
		} else {
			if (0 == (ulSubnet & ulMask)) {
				objErrCode = cmsg_show("JE0314");
				giErrNum = 1;
				return false;
			}
		}
	}
	return true;
}

function chknet_CheckIPv4Dgw(ulIpAddr, ulSubnet, ulGateway) {
	if (ulGateway == ulIpAddr) {
		objErrCode = cmsg_show("JE0314");
		giErrNum = 1;
		return false;
	} else {
		ulGateway &= ulSubnet;
		ulIpAddr &= ulSubnet;
		if (ulGateway != ulIpAddr) {
			objErrCode = cmsg_show("JE0314");
			giErrNum = 1;
			return false;
		}
	}
	return true;
}

function chknet_CheckIPv4Dns(ulDns, ulIpAddr, ulSubnet) {
	if (!chknet_CheckClass(ulDns)) {
		objErrCode = cmsg_show("JE0314");
		return false;
	}
	if (ulIpAddr == ulDns) {
		objErrCode = cmsg_show("JE0314");
		return false;
	}
	if ((ulIpAddr & ulSubnet) == (ulDns & ulSubnet)) {
		if (0 == (ulDns & ~ulSubnet)) {
			objErrCode = cmsg_show("JE0314");
			return false;
		}
		if ((0xFFFFFFFF & ~ulSubnet) == (ulDns & ~ulSubnet)) {
			objErrCode = cmsg_show("JE0314");
			return false;
		}
	}
	return true;
}

function chknet_CheckClass(ulIpAddr) {
	if (0 == ulIpAddr) {
		return false;
	} else if (4294967295 == ulIpAddr) {
		return false;
	} else if (4026531840 <= ulIpAddr) {
		return false;
	} else if (3758096384 <= ulIpAddr && 4026531839 >= ulIpAddr) {
		return false;
	} else if (2130706432 <= ulIpAddr && 2147483647 >= ulIpAddr) {
		return false;
	}
	return true;
}

function chknet_portUsedNo(str, str1, str2, str3, str4, str5) {
	var port = parseInt(str);
	var port1 = parseInt(str1);
	var port2 = parseInt(str2);
	var port3 = parseInt(str3);
	var port4 = parseInt(str4);
	var port5 = parseInt(str5);
	if (port == port1 || port == port2 || port == port3 || port == port4 || port == port5) {
		objErrCode = cmsg_show("JE0315");
		return false;
	}
	return true;
}

function chknet_CheckMultiAddr(sMultiAddr) {
	var iAddr = new Array();
	var iIndex;
	var iChar = capi_CharCounter(sMultiAddr, ":");
	if (sMultiAddr.length == 0) {
		objErrCode = cmsg_show("JE0103");
		return false;
	}
	if (chknet_ipaddr_familly(sMultiAddr) == "IPv6") {
		if ((sMultiAddr.length > 45) || (iChar > 7)) {
			objErrCode = cmsg_show("JE0201");
			return false;
		}
		for (var iIndex = 0; iIndex < iChar; iIndex++) {
			if (sMultiAddr.split(":")[iIndex].length > 4) {
				objErrCode = cmsg_show("JE0201");
				return false;
			}
		}
		var sLaOct = sMultiAddr.split(":")[iChar];
		if (capi_CharCounter(sMultiAddr, ".") == 3) {
			objErrCode = cmsg_show("JE0201");
			return false;
		} else {
			if (sLaOct.length > 4) {
				objErrCode = cmsg_show("JE0201");
				return false;
			}
		}
		var iPosi = sMultiAddr.indexOf("::");
		if (iPosi != -1) {
			if (sMultiAddr.substring(iPosi + 2, iPosi + 3) == ":") {
				objErrCode = cmsg_show("JE0201");
				return false;
			}
			if (sMultiAddr.substring(iPosi + 2).indexOf("::") != -1) {
				objErrCode = cmsg_show("JE0201");
				return false;
			}
		}
		var strSymbol = "abcdef:";
		if (!capi_isNumSymbol(sMultiAddr, strSymbol)) {
			objErrCode = cmsg_show("JE0201");
			return false;
		}
		var sStOct = sMultiAddr.substring(0, 2).toLowerCase();
		if (sStOct != "ff") {
			objErrCode = cmsg_show("JE0201");
			return false;
		}
	} else {
		if (capi_CharCounter(sMultiAddr, ".") != 3) {
			objErrCode = cmsg_show("JE0201");
			return false;
		}
		for (var iIndex = 0; iIndex < 4; iIndex++) {
			iAddr[iIndex] = parseInt(sMultiAddr.split(".")[iIndex]);
			if (!capi_isDigit(iAddr[iIndex])) {
				objErrCode = cmsg_show("JE0201");
				return false;
			}
			if (iAddr[iIndex].length == 0) {
				objErrCode = cmsg_show("JE0201");
				return false;
			}
		}
		if ((iAddr[0] < 224) || (iAddr[0] > 239)) {
			objErrCode = cmsg_show("JE0201");
			return false;
		}
		for (iIndex = 2; iIndex <= 4; iIndex++) {
			if ((iAddr[iIndex - 1] < 0) || (255 < iAddr[iIndex - 1])) {
				objErrCode = cmsg_show("JE0201");
				return false;
			}
		}
	}
	return true;
}

function chknet_CheckMultiTtl(sTtl) {
	if (sTtl.length == 0) {
		objErrCode = cmsg_show("JE0104");
		return false;
	}
	if (!capi_isDigit(sTtl)) {
		objErrCode = cmsg_show("JE0202");
		return false;
	}
	if ((sTtl < 1) || (254 < sTtl)) {
		objErrCode = cmsg_show("JE0201");
		return false;
	}
	return true;
}

function chknet_ManualPort(sPort, strSevrer, ghttpsmode) {
	var sPortNum = sPort;
	var iPortNum = 0;
	if (sPortNum.length == 0) {
		objErrCode = cmsg_show("JE0102");
		return false;
	}
	if (!capi_isDigit(sPortNum)) {
		objErrCode = cmsg_show("JE0202");
		return false;
	}
	iPortNum = parseInt(sPortNum, 10);
	if ((iPortNum < 1024) || (50000 < iPortNum)) {
		objErrCode = cmsg_show("JE0201");
		return false;
	}
	if ((iPortNum % 2) == 1) {
		objErrCode = cmsg_show("JE0203");
		return false;
	}
	return chknet_portReservedNo(sPortNum, strSevrer, ghttpsmode);
}

function chknet_ipaddr_familly(sAddr) {
	var sFamilly = "none";
	if (capi_CharCounter(sAddr, ":") >= 2) {
		sFamilly = "IPv6";
	} else if (capi_CharCounter(sAddr, ".") == 3) {
		sFamilly = "IPv4";
	}
	return sFamilly;
}

function chknet_RepIpv6_2(sAddr) {
	var sRepAddr = sAddr.split(":");
	for (var i = 0; i < sRepAddr.length; i++) {
		sRepAddr[i] = parseInt("0x" + sRepAddr[i]);
	}
	return sRepAddr;
}

function chknet_portSysResvdNo(str) {
	var iSysResvdNo = new Array(59000, 60999);
	var port = parseInt(str);
	if ((port >= iSysResvdNo[0]) && (port <= iSysResvdNo[1])) {
		objErrCode = cmsg_show("JE0315");
		return false;
	}
	return true;
}

function chknet_CheckSetPortNo(sSetPort, sHttpPort, sHttpsPort, ihttps) {
	var sRetPortNo = 0;
	if (sSetPort == "") {
		if (ihttps == 0) {
			sRetPortNo = parseInt(sHttpPort);
		} else {
			sRetPortNo = parseInt(sHttpsPort);
		}
	} else {
		sRetPortNo = parseInt(sSetPort);
	}
	return sRetPortNo;
}

function chknet_portUsedNo_Nossl(str, str1, str2, str3, str4) {
	var port = parseInt(str);
	var port1 = parseInt(str1);
	var port2 = parseInt(str2);
	var port3 = parseInt(str3);
	var port4 = parseInt(str4);
	if (port == port1 || port == port2 || port == port3 || port == port4) {
		objErrCode = cmsg_show("JE0315");
		return false;
	}
	return true;
}