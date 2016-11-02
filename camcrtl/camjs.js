

// curl "http://67.204.164.159:9293/cgi-bin/nphControlCamera?Width=320&Height=240&clientWidth=320&clientHeight=240&Direction=Direct&NewPosition.x=0&NewPosition.y=100&Language=0"
// curl "http://67.210.198.15:9092/cgi-bin/nphControlCamera?clientWidth=320&clientHeight=240&Direction=Direct&NewPosition.x=160&NewPosition.y=0"

var giRequestID = new Array(4);
var gsTitle = new Array(4);
var gsAddr = new Array(4);
var giRetryID = new Array(4);
var giDisconnectID = new Array(4);
var giConnectFlg = new Array(false, false, false, false);
var gsHttpTBL = new Array("http://", "https://");
var gsReqURI = new Array("/cgi-bin/camera?resolution=320", "/SnapshotJPEG?Resolution=320x240");
var gsReqURIIdx = new Array(4);
var gihttps = 0;

function InitThisPage() {
	var iCamNum = 1;
	var sAddr1 = "67.210.198.15:8081";
	var sAddr2 = "67.210.198.15:7271";
	var sAddr3 = "67.210.198.15:9092";
	var sAddr4 = "67.204.164.159:9293";
	var sAddr5 = "67.210.198.15:8919";
	var sAddr6 = "";
	var sAddr7 = "";
	var sAddr8 = "";
	var sAddr9 = "";
	var sAddr10 = "";
	var sAddr11 = "";
	var sAddr12 = "";
	var sAddr13 = "";
	var sAddr14 = "";
	var sAddr15 = "";
	var sAddr16 = "";
	var sTitle1 = "Downtown";
	var sTitle2 = "Emkay";
	var sTitle3 = "River Park";
	var sTitle4 = "BPRD";
	var sTitle5 = "Pavilion";
	var sTitle6 = "";
	var sTitle7 = "";
	var sTitle8 = "";
	var sTitle9 = "";
	var sTitle10 = "";
	var sTitle11 = "";
	var sTitle12 = "";
	var sTitle13 = "";
	var sTitle14 = "";
	var sTitle15 = "";
	var sTitle16 = "";
	try {
		switch (top.frmLeft.menubar_GetMultiMode()) {
			case 3:
				iCamNum = 5;
				break;
			case 4:
				iCamNum = 9;
				break;
			case 5:
				iCamNum = 13;
				break;
		}
	} catch (e) {}
	for (var i = 0; i < 4; i++) {
		gsTitle[i] = eval("sTitle" + iCamNum);
		gsAddr[i] = eval("sAddr" + iCamNum++);
	}
	for (var i = 0; i < gsAddr.length; i++) {
		gsReqURIIdx[i] = 0;
		if ((gsAddr[i].substr(0, 7) != "http://") && (gsAddr[i].substr(0, 8) != "https://")) {
			if (chknet_ipaddr_familly(gsAddr[i]) == "IPv6") {
				if ((gsAddr[i].indexOf("[") < 0) && (gsAddr[i].indexOf("]") < 0)) {
					gsAddr[i] = "[" + gsAddr[i] + "]";
				}
			}
		}
	}
	try {
		top.frmLeft.menubar_ClearOneTimeFlag();
	} catch (e) {}
	this.idTitle0.innerHTML = capi_ChangeSpecialSign(gsTitle[0]);
	this.idTitle1.innerHTML = capi_ChangeSpecialSign(gsTitle[1]);
	this.idTitle2.innerHTML = capi_ChangeSpecialSign(gsTitle[2]);
	this.idTitle3.innerHTML = capi_ChangeSpecialSign(gsTitle[3]);
	document.getElementById("img00").style.visibility = "visible";
	document.getElementById("img10").style.visibility = "visible";
	document.getElementById("img20").style.visibility = "visible";
	document.getElementById("img30").style.visibility = "visible";
	document.getElementById("img01").style.visibility = "hidden";
	document.getElementById("img11").style.visibility = "hidden";
	document.getElementById("img21").style.visibility = "hidden";
	document.getElementById("img31").style.visibility = "hidden";
	document.getElementById("img02").style.visibility = "hidden";
	document.getElementById("img12").style.visibility = "hidden";
	document.getElementById("img22").style.visibility = "hidden";
	document.getElementById("img32").style.visibility = "hidden";
	if (gsAddr[0] != "") {
		RequestJpegPic1(0);
	}
	if (gsAddr[1] != "") {
		RequestJpegPic1(1);
	}
	if (gsAddr[2] != "") {
		RequestJpegPic1(2);
	}
	if (gsAddr[3] != "") {
		RequestJpegPic1(3);
	}
}

function RequestJpegPic1(iIndex) {
	var sAddr;
	var objDate = new Date();
	if (giRetryID[iIndex] != 0) {
		clearTimeout(giRetryID[iIndex]);
		giRetryID[iIndex] = 0;
	}
	var strFunc = "ErrorProcessing1(" + iIndex + ")";
	giRetryID[iIndex] = setTimeout(strFunc, 100 * 1000);
	if (gsAddr[iIndex] != "") {
		if ((gsAddr[iIndex].substr(0, 7) == "http://") || (gsAddr[iIndex].substr(0, 8) == "https://")) {
			document.all("imgView" + iIndex + "1").src = gsAddr[iIndex] + gsReqURI[gsReqURIIdx[iIndex]] + "&page=" + objDate.getTime() + "&Language=0";
		} else {
			document.all("imgView" + iIndex + "1").src = gsHttpTBL[gihttps] + gsAddr[iIndex] + gsReqURI[gsReqURIIdx[iIndex]] + "&page=" + objDate.getTime() + "&Language=0";
		}
	}
}

function DispJpegPic1(iIndex) {
	if (giRetryID[iIndex] != 0) {
		clearTimeout(giRetryID[iIndex]);
		giRetryID[iIndex] = 0;
	}
	if (giDisconnectID[iIndex] != 0) {
		clearTimeout(giDisconnectID[iIndex]);
		giDisconnectID[iIndex] = 0;
	}
	document.getElementById("img" + iIndex + "0").style.visibility = "hidden";
	document.getElementById("img" + iIndex + "1").style.visibility = "visible";
	document.getElementById("img" + iIndex + "2").style.visibility = "hidden";
	strFunc = "RequestJpegPic2(" + iIndex + ")";
	giRequestID[iIndex] = setTimeout(strFunc, 500);
	strFunc = "DisconnectAlert(" + iIndex + ")";
	giDisconnectID[iIndex] = setTimeout(strFunc, 120 * 1000);
	giConnectFlg[iIndex] = true;
}

function RequestJpegPic2(iIndex) {
	alert ("RequestJpegPic2: " + iIndex);
	var sAddr;
	var objDate = new Date();
	if (giRetryID[iIndex] != 0) {
		clearTimeout(giRetryID[iIndex]);
		giRetryID[iIndex] = 0;
	}
	var strFunc = "ErrorProcessing2(" + iIndex + ")";
	giRetryID[iIndex] = setTimeout(strFunc, 100 * 1000);
	if (gsAddr[iIndex] != "") {
		if ((gsAddr[iIndex].substr(0, 7) == "http://") || (gsAddr[iIndex].substr(0, 8) == "https://")) {
// 			alert( gsAddr[iIndex] + gsReqURI[gsReqURIIdx[iIndex]] + "&page=" + objDate.getTime() + "&Language=0" );
			document.all("imgView" + iIndex + "2").src = gsAddr[iIndex] + gsReqURI[gsReqURIIdx[iIndex]] + "&page=" + objDate.getTime() + "&Language=0";
		} else {
// 			alert (gsHttpTBL[gihttps] + gsAddr[iIndex] + gsReqURI[gsReqURIIdx[iIndex]] + "&page=" + objDate.getTime() + "&Language=0");
			document.all("imgView" + iIndex + "2").src = gsHttpTBL[gihttps] + gsAddr[iIndex] + gsReqURI[gsReqURIIdx[iIndex]] + "&page=" + objDate.getTime() + "&Language=0";
		}
	}
}

function DispJpegPic2(iIndex) {
	if (giRetryID[iIndex] != 0) {
		clearTimeout(giRetryID[iIndex]);
		giRetryID[iIndex] = 0;
	}
	if (giDisconnectID[iIndex] != 0) {
		clearTimeout(giDisconnectID[iIndex]);
		giDisconnectID[iIndex] = 0;
	}
	document.getElementById("img" + iIndex + "0").style.visibility = "hidden";
	document.getElementById("img" + iIndex + "1").style.visibility = "hidden";
	document.getElementById("img" + iIndex + "2").style.visibility = "visible";
	strFunc = "RequestJpegPic1(" + iIndex + ")";
	giRequestID[iIndex] = setTimeout(strFunc, 500);
	strFunc = "DisconnectAlert(" + iIndex + ")";
	giDisconnectID[iIndex] = setTimeout(strFunc, 120 * 1000);
	giConnectFlg[iIndex] = true;
}

function OpenLiveWindow(iIndex) {
	if (gsAddr[iIndex] != "") {
		if ((gsAddr[iIndex].substr(0, 7) == "http://") || (gsAddr[iIndex].substr(0, 8) == "https://")) {
			window.open(gsAddr[iIndex]);
		} else {
			window.open(gsHttpTBL[gihttps] + gsAddr[iIndex]);
		}
	}
}

function DocWriteCamTitle(iIndex) {
	var sLine;
	var bAct = true;
	if (gsAddr[iIndex] == "") {
		bAct = false;
	}
	if (bAct) {
		sLine = "<div class=\"camera_title" + iIndex + "\" style=\"cursor:hand;\" tabindex=\"1\" onclick=\"OpenLiveWindow(" + iIndex + ");\" onkeypress=\"OpenLiveWindow(" + iIndex + ");\">";
	} else {
		sLine = "<div class=\"camera_title" + iIndex + "\">";
	}
	sLine += "<div id=\"idTitle" + iIndex + "\" class=\"14textB\">";
	sLine += "</div>";
	sLine += "</div>";
	document.write(sLine);
}

function clrTimer() {
	var iIndex;
	for (iIndex = 0; iIndex < 4; iIndex++) {
		clearTimeout(giRequestID[iIndex]);
		clearTimeout(giRetryID[iIndex]);
	}
}

function ErrorProcessing1(iIndex) {
	gsReqURIIdx[iIndex] = (gsReqURIIdx[iIndex] == 0) ? 1 : 0;
	strFunc = "RequestJpegPic1(" + iIndex + ")";
	setTimeout(strFunc, 500);
	giConnectFlg[iIndex] = false;
}

function ErrorProcessing2(iIndex) {
	gsReqURIIdx[iIndex] = (gsReqURIIdx[iIndex] == 0) ? 1 : 0;
	strFunc = "RequestJpegPic2(" + iIndex + ")";
	setTimeout(strFunc, 500);
	giConnectFlg[iIndex] = false;
}

function DisconnectAlert(iIndex) {
	if (gsTitle[iIndex] != "") {
		var strArt = gsTitle[iIndex] + "\n" + cmsg_show("JE0914");
		alert(strArt);
	} else {
		var iCamNum = 1;
		try {
			switch (top.frmLeft.menubar_GetMultiMode()) {
				case 3:
					iCamNum = 5;
					break;
				case 4:
					iCamNum = 9;
					break;
				case 5:
					iCamNum = 13;
					break;
			}
		} catch (e) {}
		iCamNum = iCamNum + iIndex;
		alert(cmsg_show("JE0915") + iCamNum + "\n" + cmsg_show("JE0914"));
	}
	strFunc = "DisconnectAlert(" + iIndex + ")";
	giDisconnectID[iIndex] = setTimeout(strFunc, 30 * 1000);
}

function funcpt(pan, tilt, iIndex) {
	var url = "";
	if (gsAddr[iIndex] != "") {
		if (giConnectFlg[iIndex] == true) {
			switch (iIndex) {
				case 0:
					tilt = tilt - 27;
					break;
				case 1:
					pan = pan - 373;
					tilt = tilt - 27;
					break;
				case 2:
					tilt = tilt - 310;
					break;
				case 3:
					pan = pan - 373;
					tilt = tilt - 310;
					break;
				default:
					break;
			}
			var x_step = 29;
			var y_step = 26.6;
			var y1 = 0;
			var y2 = y1 + y_step;
			for (var i = -4; i <= 4; i++) {
				if ((tilt >= y1) && (tilt <= y2)) {
					break;
				}
				y1 += y_step;
				y2 += y_step;
			}
			var x1 = 0;
			var x2 = x1 + x_step;
			for (var j = -5; j <= 5; j++) {
				if ((pan >= x1) && (pan <= x2)) {
					break;
				}
				x1 += x_step;
				x2 += x_step;
			}
			if (i == 5 || j == 6) {
				return false;
			}
			if ((gsAddr[iIndex].substr(0, 7) == "http://") || (gsAddr[iIndex].substr(0, 8) == "https://")) {
				if (gsReqURIIdx[iIndex] == 0) {
					url = gsAddr[iIndex] + "/cgi-bin/camctrl?pan=" + j + "&tilt=" + i + "&Language=0";
				} else {
					url = gsAddr[iIndex] + "/cgi-bin/nphControlCamera?Width=320&Height=240&clientWidth=320&clientHeight=240&Direction=Direct&NewPosition.x=" + pan + "&NewPosition.y=" + tilt + "&Language=0";
				}
			} else {
				if (gsReqURIIdx[iIndex] == 0) {
					url = gsHttpTBL[gihttps] + gsAddr[iIndex] + "/cgi-bin/camctrl?pan=" + j + "&tilt=" + i + "&Language=0";
				} else {
					url = gsHttpTBL[gihttps] + gsAddr[iIndex] + "/cgi-bin/nphControlCamera?Width=320&Height=240&clientWidth=320&clientHeight=240&Direction=Direct&NewPosition.x=" + pan + "&NewPosition.y=" + tilt + "&Language=0";
				}
			}
			camctrl_CgiSend(gsCgiKind[3], url);
		}
	}
}

function MouseClick(iIndex) {
	funcpt(event.clientX, event.clientY, iIndex);
}

function MouseWheel(iIndex) {
	var url = "";
	if (gsAddr[iIndex] != "") {
		if (giConnectFlg[iIndex] == true) {
			var FuncURL = "";
			if (event.wheelDelta > 0) {
				FuncURL += "times=up&zoom=3";
			} else {
				FuncURL += "times=down&zoom=-3";
			}
			if ((gsAddr[iIndex].substr(0, 7) == "http://") || (gsAddr[iIndex].substr(0, 8) == "https://")) {
				url = gsAddr[iIndex] + "/cgi-bin/camctrl?" + FuncURL + "&Language=0";
			} else {
				url = gsHttpTBL[gihttps] + gsAddr[iIndex] + "/cgi-bin/camctrl?" + FuncURL + "&Language=0";
			}
			camctrl_CgiSend(gsCgiKind[3], url);
		}
	}
}