
var gsCountry = new Array(
	"IS",
	"IE",
	"AZ",
	"AF",
	"US",
	"VI",
	"AS",
	"UM",
	"AE",
	"DZ",
	"AR",
	"AW",
	"AL",
	"AM",
	"AI",
	"AO",
	"AG",
	"AD",
	"YE",
	"GB",
	"IO",
	"VG",
	"IL",
	"IT",
	"IQ",
	"IR",
	"IN",
	"ID",
	"WF",
	"UG",
	"UA",
	"UZ",
	"UY",
	"EC",
	"EG",
	"EE",
	"ET",
	"ER",
	"SV",
	"AU",
	"AT",
	"AX",
	"OM",
	"NL",
	"AN",
	"GH",
	"CV",
	"GG",
	"GY",
	"KZ",
	"QA",
	"CA",
	"GA",
	"CM",
	"GM",
	"KH",
	"MP",
	"GN",
	"GW",
	"CY",
	"CU",
	"GR",
	"KI",
	"KG",
	"GT",
	"GP",
	"GU",
	"KW",
	"CK",
	"GL",
	"CX",
	"GE",
	"GD",
	"HR",
	"KY",
	"KE",
	"CI",
	"CC",
	"CR",
	"KM",
	"CO",
	"CG",
	"CD",
	"SA",
	"WS",
	"ST",
	"BL",
	"ZM",
	"PM",
	"SM",
	"MF",
	"SL",
	"DJ",
	"GI",
	"JE",
	"JM",
	"SY",
	"SG",
	"ZW",
	"CH",
	"SE",
	"SD",
	"SJ",
	"ES",
	"SR",
	"LK",
	"SK",
	"SI",
	"SZ",
	"SC",
	"GQ",
	"SN",
	"RS",
	"KN",
	"VC",
	"SH",
	"LC",
	"SO",
	"SB",
	"TC",
	"TH",
	"KR",
	"TW",
	"TJ",
	"TZ",
	"CZ",
	"TD",
	"CF",
	"CN",
	"TN",
	"KP",
	"CL",
	"TV",
	"DK",
	"DE",
	"TG",
	"TK",
	"DO",
	"DM",
	"TT",
	"TM",
	"TR",
	"TO",
	"NG",
	"NR",
	"NA",
	"AQ",
	"NU",
	"NI",
	"NE",
	"JP",
	"EH",
	"NC",
	"NZ",
	"NP",
	"NF",
	"NO",
	"BH",
	"HT",
	"PK",
	"VA",
	"PA",
	"VU",
	"BS",
	"PG",
	"BM",
	"PW",
	"PY",
	"BB",
	"PS",
	"HU",
	"BD",
	"TL",
	"PN",
	"FJ",
	"PH",
	"FI",
	"BT",
	"BV",
	"PR",
	"FO",
	"FK",
	"BR",
	"FR",
	"GF",
	"PF",
	"TF",
	"BG",
	"BF",
	"BN",
	"BI",
	"HM",
	"VN",
	"BJ",
	"VE",
	"BY",
	"BZ",
	"PE",
	"BE",
	"PL",
	"BA",
	"BW",
	"BO",
	"PT",
	"HK",
	"HN",
	"MH",
	"MO",
	"MK",
	"MG",
	"YT",
	"MW",
	"ML",
	"MT",
	"MQ",
	"MY",
	"IM",
	"FM",
	"ZA",
	"GS",
	"MM",
	"MX",
	"MU",
	"MR",
	"MZ",
	"MC",
	"MV",
	"MD",
	"MA",
	"MN",
	"ME",
	"MS",
	"JO",
	"LA",
	"LV",
	"LT",
	"LY",
	"LI",
	"LR",
	"RO",
	"LU",
	"RW",
	"LS",
	"LB",
	"RE",
	"RU",
	""
);

function capi_DispError(objForm, objMsg) {
	try {
		objForm.focus();
		objForm.select();
	} catch (e) {}
	alert(objMsg);
	return false;
}

function capi_FormatNum(iNum) {
	var strRet = iNum;
	if (iNum < 10) {
		strRet = "0" + iNum;
	}
	return strRet;
}

function capi_CharCounter(sStr, cChar) {
	var iCnt = 0;
	var iPtr = 0;
	while (iPtr < sStr.length) {
		iPtr = sStr.indexOf(cChar, iPtr);
		if (iPtr == -1) {
			break;
		}
		iCnt++;
		iPtr++;
	}
	return iCnt;
}

function capi_ChangeSpecialSign(sStr) {
	while (sStr.indexOf("<") != -1) {
		sStr = sStr.replace("<", "&lt;");
	}
	while (sStr.indexOf(">") != -1) {
		sStr = sStr.replace(">", "&gt;");
	}
	while (sStr.indexOf(" ") != -1) {
		sStr = sStr.replace(" ", "&nbsp;");
	}
	return sStr;
}

function capi_ReturnSpecialSign(sStr) {
	while (sStr.indexOf("&lt;") != -1) {
		sStr = sStr.replace("&lt;", "<");
	}
	while (sStr.indexOf("&gt;") != -1) {
		sStr = sStr.replace("&gt;", ">");
	}
	return sStr;
}

function capi_IncludeSpace(str) {
	for (var i = 0; i < str.length; i++) {
		var ch = str.charAt(i);
		if ((ch == ' ') || (ch == '\n') || (ch == '\t')) {
			return true;
		}
	}
	return false;
}

function capi_includeCtrlCode(str) {
	for (var iIndex = 0; iIndex < str.length; iIndex++) {
		cTmp = str.charAt(iIndex);
		iTmp = str.charCodeAt(iIndex);
		if ((0x00 <= iTmp) && (iTmp <= 0x1f)) {
			return true;
		}
	}
	return false;
}

function capi_includeHalfKana(str) {
	return false;
}

function capi_includeZenkaku(str) {
	for (var i = 0; i < str.length; i++) {
		var c = str.charCodeAt(i);
		if ((c > 255) && ((c < 0xff61) || (0xff9f < c))) {
			return true;
		}
	}
	return false;
}

function capi_isDigit(str) {
	for (var i = 0; i < str.length; i++) {
		var ch = str.charAt(i);
		if (ch < '0' || ch > '9') {
			return false;
		}
	}
	if ((str.length >= 2) && (str.substring(0, 1) == "0")) {
		return false;
	}
	return true;
}

function capi_isBlank(str) {
	for (var i = 0; i < str.length; i++) {
		var ch = str.charAt(i);
		if (ch != ' ' && ch != '\n' && ch != '\t') {
			return false;
		}
	}
	return true;
}

function capi_isBlank2(str) {
	for (var i = 0; i < str.length; i++) {
		var ch = str.charAt(i);
		if (ch != '\n' && ch != '\t') {
			return false;
		}
	}
	return true;
}

function capi_isSpace(str) {
	for (var i = 0; i < str.length; i++) {
		var ch = str.charAt(i);
		if (ch != ' ') {
			return false;
		}
	}
	return true;
}

function capi_isAlpha(str) {
	var sValid = "abcdefghijklmnopqrstuvwxyz";
	var sWork = str.toLowerCase();
	for (var i = 0; i < sWork.length; i++) {
		var ch = sWork.charAt(i);
		if (sValid.indexOf(ch) < 0) {
			return false;
		}
	}
	return true;
}

function capi_isAlphaNum(str) {
	var sValid = "abcdefghijklmnopqrstuvwxyz0123456789";
	var sWork = str.toLowerCase();
	for (var i = 0; i < sWork.length; i++) {
		var ch = sWork.charAt(i);
		if (sValid.indexOf(ch) < 0) {
			return false;
		}
	}
	return true;
}

function capi_isAlphaNumSymbol(str, strSymbol) {
	var sValid = "abcdefghijklmnopqrstuvwxyz0123456789" + strSymbol;
	var sWork = str.toLowerCase();
	for (var i = 0; i < sWork.length; i++) {
		var ch = sWork.charAt(i);
		if (sValid.indexOf(ch) < 0) {
			return false;
		}
	}
	return true;
}

function capi_isAlphaNumSP(str) {
	var sValid = "abcdefghijklmnopqrstuvwxyz0123456789 ";
	var sWork = str.toLowerCase();
	for (var i = 0; i < sWork.length; i++) {
		var ch = sWork.charAt(i);
		if (sValid.indexOf(ch) < 0) {
			return false;
		}
	}
	return true;
}

function capi_isAlphaSymbol(str, strSymbol) {
	var sValid = "abcdefghijklmnopqrstuvwxyz" + strSymbol;
	var sWork = str.toLowerCase();
	for (var i = 0; i < sWork.length; i++) {
		var ch = sWork.charAt(i);
		if (sValid.indexOf(ch) < 0) {
			return false;
		}
	}
	return true;
}

function capi_isNumSymbol(str, strSymbol) {
	var sValid = "0123456789" + strSymbol;
	var sWork = str.toLowerCase();
	for (var i = 0; i < sWork.length; i++) {
		var ch = sWork.charAt(i);
		if (sValid.indexOf(ch) < 0) {
			return false;
		}
	}
	return true;
}

function capi_ValueCmp(str1, str2) {
	if (str1 != str2) {
		return false;
	}
	return true;
}

function capi_ContryChk(str) {
	for (var i = 0; gsCountry[i] != ""; i++) {
		if ((str.indexOf(gsCountry[i], 0)) != -1) {
			return true;
		}
	}
	return false;
}