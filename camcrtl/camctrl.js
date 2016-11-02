// alert( "camctrl.js" ) ;
var camctrl_kind = 0;
var camctrl_MouseBtn = 0;
var camtimer_cnt = 0;
var camtimer_cntpad = 0;
var camtimer1;
var camtimer3 = 0;
var camtimer4;
var camtimer5;
var camtimer6;
var camstrURL;
var zoom_mode = 0;
var zoom_mode_wait = 0;
var zoom_whl_cnt = 0;
var disableClick_mode = 0;
var gsCgiKind = new Array("DIRECT", "CAMCTL", "BACFS", "MULTI");
var gsCgiCtrl = new Array();
gsCgiCtrl["DIRECT"] = "/cgi-bin/directctrl?";
gsCgiCtrl["CAMCTL"] = "/cgi-bin/camctrl?";
gsCgiCtrl["BACFS"] = "/cgi-bin/back_focus?";
var gsBriCgi = new Array("bright=down", "bright=1", "bright=up");
var gsBacFsCgi = new Array("manual=near", "manual=reset", "manual=far", "auto=on");
var CtrlKindTbl = new Array(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15);
var Pan_Tbl = new Array(-14, -14, -12, -12, -10, -10, -9, -9, -8, -8, -6, -6, -3, -3, 0, 0, 0, 0, 0, 3, 3, 6, 6, 8, 8, 9, 9, 10, 10, 12, 12, 14, 14);
var Tilt_Tbl = new Array(-14, -14, -12, -12, -10, -10, -9, -9, -8, -8, -6, -6, -3, -3, -3, 0, 0, 0, 3, 3, 3, 6, 6, 8, 8, 9, 9, 10, 10, 12, 12, 14, 14);
var Zoom_Tbl = new Array(4, 4, 4, 4, 3, 3, 3, 3, 2, 2, 2, 2, 1, 1, 1, 1, 0, -1, -1, -1, -1, -2, -2, -2, -2, -3, -3, -3, -3, -4, -4, -4, -4);
var Focus_Tbl = new Array(4, 4, 4, 4, 3, 3, 3, 3, 2, 2, 2, 2, 1, 1, 1, 1, 0, -1, -1, -1, -1, -2, -2, -2, -2, -3, -3, -3, -3, -4, -4, -4, -4);
var Focus_Tbl2 = new Array(-4, -4, -4, -4, -3, -3, -3, -3, -2, -2, -2, -2, -1, -1, -1, -1, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4);
var gCamName;
var PosTbl = new Array();
var gipantilt_case = 1;
var gizoom_down_case = 2;
var gizoom_up_case = 3;
var gifocus_near_case = 4;
var gifocus_far_case = 5;
var gibright_down_case = 6;
var gibright_up_case = 7;
var gizoom_case = 8;
var gifocus_case = 9;
var givzoom_times_down_case = 12;
var givzoom_times_up_case = 13;
var gibfocus_near_case = 14;
var gibfocus_far_case = 15;
var goFormInf;

function camctrl_SetFocusZoom(focus, zoom) {
	var GetMovePosi;
	var FocusPosi = Math.abs(16 - focus);
	var ZoomPosi = Math.abs(16 - zoom);
	if (FocusPosi > ZoomPosi) {
		GetMovePosi = CtrlKindTbl[8];
	} else if (FocusPosi < ZoomPosi) {
		GetMovePosi = CtrlKindTbl[7];
	} else {
		GetMovePosi = 0;
	}
	return GetMovePosi;
}

function camctrl_RetScopeX(iX) {
	var iIndex;
	if (iX < 12) {
		iIndex = parseInt(iX / 3);
	} else if ((iX >= 12) && (iX < 36)) {
		iIndex = parseInt(iX / 2) - 2;
	} else if (iX == 36) {
		iIndex = 16;
	} else if ((iX >= 37) && (iX < 60)) {
		iIndex = parseInt((iX - 1) / 2) - 1;
	} else {
		iIndex = 9 + parseInt((iX - 1) / 3);
	}
	return iIndex;
}

function camctrl_RetScopeY(iY) {
	var iIndex;
	if (iY < 24) {
		iIndex = parseInt(iY / 2);
	} else if ((iY >= 24) && (iY <= 32)) {
		iIndex = parseInt(iY / 1) - 12;
	} else {
		iIndex = 5 + parseInt((iY - 1) / 2);
	}
	return iIndex;
}

function camctrl_SetPositionTbl(x1, x2, y1, y2, id) {
	PosTbl.push(new Array(x1, x2, y1, y2, id));
}

function camctrl_MouseDown(X, Y) {
	var IndexX;
	var IndexY;
	var id;
	if (disableClick_mode == 1) {
		return;
	}
	if (camctrl_kind != 0) {
		return;
	}
	camctrl_MouseBtn = event.button;
	id = event.srcElement.id;
	for (i = 0; i < PosTbl.length; i++) {
		if (PosTbl[i][4] == id) {
			if ((X >= PosTbl[i][0]) && (X <= PosTbl[i][1]) && (Y >= PosTbl[i][2]) && (Y <= PosTbl[i][3])) {
				camctrl_ZoomStop();
				IndexX = camctrl_RetScopeX(X - PosTbl[i][0]);
				IndexY = camctrl_RetScopeY(Y - PosTbl[i][2]);
				if (camctrl_MouseBtn == 1) {
					camctrl_kind = CtrlKindTbl[i];
				} else if ((camctrl_MouseBtn == 2) && (i == 0)) {
					camctrl_kind = camctrl_SetFocusZoom(IndexX, IndexY);
				}
				break;
			}
		}
	}
	switch (camctrl_kind) {
		case 1:
			camctrl_pantilt_proc(IndexX, IndexY);
			M.location = camstrURL;
			if (gihttps == 0) {
				camtimer1 = setInterval("camctrl_timctrlpad(camstrURL)", 50);
			} else {
				camtimer1 = setTimeout("camctrl_timctrlpad2(camstrURL)", 500);
			}
			break;
		case 8:
			camctrl_zoom_proc(IndexY);
			M.location = camstrURL;
			if (gihttps == 0) {
				camtimer1 = setInterval("camctrl_timctrlpad(camstrURL)", 100);
			} else {
				camtimer1 = setTimeout("camctrl_timctrlpad2(camstrURL)", 500);
			}
			break;
		case 9:
			camctrl_focus_proc(IndexX);
			M.location = camstrURL;
			if (gihttps == 0) {
				camtimer1 = setInterval("camctrl_timctrlpad(camstrURL)", 100);
			} else {
				camtimer1 = setTimeout("camctrl_timctrlpad2(camstrURL)", 500);
			}
			break;
		case 2:
			if (gihttps == 0) {
				camctrl_ChgDirectCtrl('zoom=-4');
				camtimer1 = setInterval("camctrl_timctrl(camstrURL)", 100);
			} else {
				camctrl_ChgDirectCtrl('zoom=-3');
				camtimer1 = setTimeout("camctrl_timctrl2(camstrURL)", 500);
			}
			break;
		case 3:
			if (gihttps == 0) {
				camctrl_ChgDirectCtrl('zoom=4');
				camtimer1 = setInterval("camctrl_timctrl(camstrURL)", 100);
			} else {
				camctrl_ChgDirectCtrl('zoom=3');
				camtimer1 = setTimeout("camctrl_timctrl2(camstrURL)", 500);
			}
			break;
		case 4:
			if (gihttps == 0) {
				camctrl_ChgDirectCtrl('focus=-3');
				camtimer1 = setInterval("camctrl_timctrl(camstrURL)", 100);
			} else {
				camctrl_ChgDirectCtrl('focus=-2');
				camtimer1 = setTimeout("camctrl_timctrl2(camstrURL)", 500);
			}
			break;
		case 5:
			if (gihttps == 0) {
				camctrl_ChgDirectCtrl('focus=3');
				camtimer1 = setInterval("camctrl_timctrl(camstrURL)", 100);
			} else {
				camctrl_ChgDirectCtrl('focus=2');
				camtimer1 = setTimeout("camctrl_timctrl2(camstrURL)", 500);
			}
			break;
		case 6:
			camctrl_ChgCamCtrl('bright=down');
			if (gihttps == 0) {
				camtimer1 = setInterval("camctrl_timctrl(camstrURL)", 40);
			} else {
				camtimer1 = setTimeout("camctrl_timctrl2(camstrURL)", 500);
			}
			break;
		case 7:
			camctrl_ChgCamCtrl('bright=up');
			if (gihttps == 0) {
				camtimer1 = setInterval("camctrl_timctrl(camstrURL)", 40);
			} else {
				camtimer1 = setTimeout("camctrl_timctrl2(camstrURL)", 500);
			}
			break;
		case 10:
			camctrl_ChgBackFocus('manual=near');
			camtimer1 = setInterval("camctrl_timctrl_bkfocus(camstrURL)", 25);
			break;
		case 11:
			camctrl_ChgBackFocus('manual=far');
			camtimer1 = setInterval("camctrl_timctrl_bkfocus(camstrURL)", 25);
			break;
	}
}

function camctrl_MouseUp(X, Y) {
	if (camctrl_MouseBtn != event.button) {
		return;
	}
	switch (camctrl_kind) {
		case 0:
			break;
		case 1:
		case 8:
		case 9:
			camctrl_pantilt_stop();
			camctrl_DisClickTimerStart();
			break;
		case 2:
		case 3:
			if (gihttps == 0) {
				camctrl_ChgDirectCtrl('zoom=0');
				camctrl_TimClear();
				camctrl_DisClickTimerStart();
			} else {
				camstrURL = "/cgi-bin/directctrl?zoom=0&Language=0";
				camctrl_TimClear();
				camctrl_DisClickTimerStart();
			}
			break;
		case 4:
		case 5:
			if (gihttps == 0) {
				camctrl_ChgDirectCtrl('focus=0');
				camctrl_TimClear();
				camctrl_DisClickTimerStart();
			} else {
				camstrURL = "/cgi-bin/directctrl?focus=0&Language=0";
				camctrl_TimClear();
				camctrl_DisClickTimerStart();
			}
			break;
		default:
			camctrl_TimClear();
			camctrl_DisClickTimerStart();
			break;
	}
}

function camctrl_MouseMove(X, Y) {
	if (camctrl_kind != 0) {
		if ((X >= PosTbl[camctrl_kind - 1][0]) && (X <= PosTbl[camctrl_kind - 1][1]) && (Y >= PosTbl[camctrl_kind - 1][2]) && (Y <= PosTbl[camctrl_kind - 1][3])) {
			camctrl_MouseMoveProc(X, Y);
		} else {
			camctrl_MouseUp(X, Y);
		}
	}
}

function camctrl_MouseWheel(X, Y, Delta) {
	if ((X >= PosTbl[0][0]) && (X <= PosTbl[0][1]) && (Y >= PosTbl[0][2]) && (Y <= PosTbl[0][3])) {
		camctrl_MouseWheelProc(Delta);
	}
}

function camctrl_MouseWheelProc(Delta) {
	if (zoom_mode == 0) {
		if (Delta > 0) {
			if (zoom_whl_cnt <= 0) {
				M.location = "/cgi-bin/directctrl?zoom=2&Language=0";
				zoom_whl_cnt = zoom_whl_cnt + 1;
			} else
				M.location = "/cgi-bin/directctrl?zoom=4&Language=0";
			zoom_mode = 1;
		} else {
			if (zoom_whl_cnt <= 0) {
				M.location = "/cgi-bin/directctrl?zoom=-2&Language=0";
				zoom_whl_cnt = zoom_whl_cnt + 1;
			} else
				M.location = "/cgi-bin/directctrl?zoom=-4&Language=0";
			zoom_mode = -1;
		}
		camctrl_DisWheelTimerStart();
	} else {
		if (Delta > 0) {
			if (zoom_mode < 0) {
				if (zoom_whl_cnt <= 0) {
					M.location = "/cgi-bin/directctrl?zoom=2&Language=0";
					zoom_whl_cnt = zoom_whl_cnt + 1;
				} else
					M.location = "/cgi-bin/directctrl?zoom=4&Language=0";
				zoom_mode = 1;
				camctrl_DisWheelTimerStart();
			}
		} else {
			if (zoom_mode > 0) {
				if (zoom_whl_cnt <= 0) {
					M.location = "/cgi-bin/directctrl?zoom=-2&Language=0";
					zoom_whl_cnt = zoom_whl_cnt + 1;
				} else
					M.location = "/cgi-bin/directctrl?zoom=-4&Language=0";
				zoom_mode = -1;
				camctrl_DisWheelTimerStart();
			}
		}
	}
	camctrl_ZoomTimerStart();
}

function camctrl_MouseMoveProc(X, Y) {
	var IndexX;
	var IndexY;
	switch (camctrl_kind) {
		case 1:
			IndexX = camctrl_RetScopeX(X - PosTbl[0][0]);
			IndexY = camctrl_RetScopeY(Y - PosTbl[0][2]);
			camctrl_pantilt_proc(IndexX, IndexY);
			break;
		case 8:
			IndexX = camctrl_RetScopeX(X - PosTbl[0][0]);
			IndexY = camctrl_RetScopeY(Y - PosTbl[0][2]);
			if (camctrl_kind == camctrl_SetFocusZoom(IndexX, IndexY)) {
				camctrl_zoom_proc(IndexY);
			} else {
				camctrl_pantilt_stop();
			}
			break;
		case 9:
			IndexX = camctrl_RetScopeX(X - PosTbl[0][0]);
			IndexY = camctrl_RetScopeY(Y - PosTbl[0][2]);
			if (camctrl_kind == camctrl_SetFocusZoom(IndexX, IndexY)) {
				camctrl_focus_proc(IndexX);
			} else {
				camctrl_pantilt_stop();
			}
			break;
	}
}

function camctrl_pantilt_proc(IndexX, IndexY) {
	camstrURL = "/cgi-bin/directctrl?" + "pan=" + Pan_Tbl[IndexX] + "&tilt=" + Tilt_Tbl[IndexY] + "&Language=0";
}

function camctrl_zoom_proc(IndexY) {
	camstrURL = "/cgi-bin/directctrl?" + "zoom=" + Zoom_Tbl[IndexY] + "&Language=0";
}

function camctrl_focus_proc(IndexX) {
	if (gCamName != "DG-NS202" && gCamName != "WV-NS202") {
		camstrURL = "/cgi-bin/directctrl?" + "focus=" + Focus_Tbl2[IndexX] + "&Language=0";
	} else {
		camstrURL = "/cgi-bin/directctrl?" + "focus=" + Focus_Tbl[IndexX] + "&Language=0";
	}
}

function camctrl_pantilt_stop() {
	if (gihttps == 0) {
		clearInterval(camtimer1);
		if (camctrl_kind == 1) {
			M.location = "/cgi-bin/directctrl?pan=0&tilt=0&Language=0";
		} else if (camctrl_kind == 8) {
			M.location = "/cgi-bin/directctrl?zoom=0&Language=0";
		} else if (camctrl_kind == 9) {
			M.location = "/cgi-bin/directctrl?focus=0&Language=0";
		}
	} else {
		if (camctrl_kind == 1) {
			camstrURL = "/cgi-bin/directctrl?pan=0&tilt=0&Language=0";
		} else if (camctrl_kind == 8) {
			camstrURL = "/cgi-bin/directctrl?zoom=0&Language=0";
		} else if (camctrl_kind == 9) {
			camstrURL = "/cgi-bin/directctrl?focus=0&Language=0";
		}
	}
	camtimer_cnt = 0;
	camctrl_kind = 0;
	camctrl_MouseBtn = 0;
}

function camctrl_ChgCamCtrl(ctrlid) {
	camstrURL = "/cgi-bin/camctrl?" + ctrlid + "&Language=0";
	M.location = camstrURL;
}

function camctrl_ChgDirectCtrl(ctrlid) {
	camstrURL = "/cgi-bin/directctrl?" + ctrlid + "&Language=0";
	M.location = camstrURL;
}

function camctrl_ChgBackFocus(cParam) {
	camstrURL = "/cgi-bin/back_focus?" + cParam + "&Language=0";
	M.location = camstrURL
}

function camctrl_timctrl(camstrURL) {
	camtimer_cnt++;
	if (camtimer_cnt >= 10) {
		camtimer_mode = 1;
		camtimer_cnt = 0;
		M.location = camstrURL;
	}
}

function camctrl_timctrl2(camstrURL) {
	camtimer_mode = 1;
	M.location = camstrURL;
	if (camctrl_MouseBtn != 0) {
		camtimer1 = setTimeout("camctrl_timctrl2(camstrURL)", 500);
	}
}

function camctrl_timctrlpad(camstrURL) {
	camtimer_cntpad++;
	if (camtimer_cntpad >= 2) {
		camtimer_mode = 1;
		camtimer_cntpad = 0;
		M.location = camstrURL;
	}
}

function camctrl_timctrlpad2(camstrURL) {
	camtimer_mode = 1;
	M.location = camstrURL;
	if (camctrl_MouseBtn != 0) {
		camtimer1 = setTimeout("camctrl_timctrlpad2(camstrURL)", 500);
	}
}

function camctrl_TimClear() {
	if (gihttps == 0) {
		clearInterval(camtimer1);
	}
	camtimer_cnt = 0;
	camctrl_kind = 0;
	camctrl_MouseBtn = 0;
	camtimer_mode = 0;
}

function camctrl_ZoomTimerStart() {
	clearTimeout(camtimer3);
	camtimer3 = setTimeout("camctrl_ZoomStop()", 500);
}

function camctrl_ZoomStop() {
	if (camtimer3 != 0) {
		clearTimeout(camtimer3);
		camtimer3 = 0;
		if (gihttps == 0) {
			M.location = "/cgi-bin/directctrl?zoom=0&Language=0";
		} else {
			if ((zoom_mode_wait == 0) || (zoom_mode != 0)) {
				M.location = "/cgi-bin/directctrl?zoom=0&Language=0";
				zoom_mode_wait = 1;
			}
		}
		zoom_whl_cnt = 0;
	}
	if (gihttps == 0) {
		camctrl_EnableWheel();
	}
}

function camctrl_DisWheelTimerStart() {
	clearTimeout(camtimer4);
	if (gihttps == 0) {
		if (zoom_whl_cnt <= 0)
			camtimer4 = setTimeout("camctrl_EnableWheel()", 100);
		else
			camtimer4 = setTimeout("camctrl_EnableWheel()", 500);
	} else {
		camtimer4 = setTimeout("camctrl_EnableWheel()", 1000);
	}
}

function camctrl_EnableWheel() {
	clearTimeout(camtimer4);
	zoom_mode = 0;
	if (gihttps != 0) {
		zoom_mode_wait = 0;
	}
}

function camctrl_WinState() {
	if (!window.opener || window.opener.closed) {} else {
		window.opener.SubWin_OpenState();
	}
}

function camctrl_DisClickTimerStart() {
	disableClick_mode = 1;
	if (gihttps == 0) {
		camtimer5 = setTimeout("camctrl_EnableClick()", 100);
	} else {
		camtimer5 = setTimeout("camctrl_EnableClick()", 800);
	}
}

function camctrl_EnableClick() {
	if (disableClick_mode == 1) {
		clearTimeout(camtimer5);
		disableClick_mode = 0;
	}
}

function camctrl_ViewClick(cx, cy, pos_x, pos_y) {
	var x_step = cx / 11;
	var y_step = cy / 9;
	var y1 = 0;
	var y2 = y1 + y_step;
	var url = "";
	if (disableClick_mode == 1) {
		return;
	}
	for (var i = -4; i <= 4; i++) {
		if ((pos_y >= y1) && (pos_y <= y2)) {
			break;
		}
		y1 += y_step;
		y2 += y_step;
	}
	var x1 = 0;
	var x2 = x1 + x_step;
	for (var j = -5; j <= 5; j++) {
		if ((pos_x >= x1) && (pos_x <= x2)) {
			break;
		}
		x1 += x_step;
		x2 += x_step;
	}
	url = "pan=" + j + "&tilt=" + i;
	camctrl_CgiSend(gsCgiKind[1], url);
}

function camctrl_CgiSend(sKind, cParam) {
	if (disableClick_mode == 1) {
		return;
	}
	switch (sKind) {
		case gsCgiKind[1]:
		case gsCgiKind[2]:
			M.location = gsCgiCtrl[sKind] + cParam + "&Language=0";
			break;
		case gsCgiKind[3]:
			M.location = cParam;
			break;
	}
	camctrl_DisClickTimerStart();
}

function camctrl_timctrl_bkfocus(camstrURL) {
	camtimer_cnt++;
	if (camtimer_cnt >= 4) {
		camtimer_mode = 1;
		camtimer_cnt = 0;
		M.location = camstrURL;
	}
}

function camctrl_WindowCheck(objwin) {
	var objwin_type = 0;
	try {
		if (!objwin.closed) {
			objwin_type = 1;
		} else {
			objwin_type = 0;
		}
		return objwin_type;
	} catch (e) {
		if (typeof(objwin.document) == "object") {
			objwin_type = 1;
		} else {
			objwin_type = 0;
		}
		return objwin_type;
	}
}

function camctrl_IeVerCheck(gbEvent) {
	var sIeVerCheck = 0;
	var sUserAgent = navigator.userAgent.toLowerCase();
	var sMinorVer = navigator.appMinorVersion.toLowerCase();
	if (gbEvent == "1") {
		if (sUserAgent.indexOf("msie 6.0") != -1 && sMinorVer.indexOf("sp1") != -1) {
			sIeVerCheck = 0;
		} else {
			sIeVerCheck = 1;
		}
	}
	return sIeVerCheck;
}

function camctrl_ViewClick2(resol, pos_x, pos_y) {
	var cParam = "center_x=" + pos_x + "&center_y=" + pos_y + "&resolution=" + resol;
	camctrl_CgiSend(gsCgiKind[1], cParam);
}

function camctrl_SetCameraName(sCamName) {
	gCamName = sCamName;
}

function camctrl_KeyPress(ctrlid) {
	if (disableClick_mode == 0) {
		M.location = "/cgi-bin/camctrl?" + ctrlid + "&Language=0";
		camctrl_DisClickTimerStart();
	}
}

function camctrl_chk_Camstatus(status) {
	if (status < 2) {
		alert("Operations are currently not available.\nPlease wait for a while.");
	}
	return;
}

function camctrl_chk_Afstatus(status) {
	if (status == 1) {
		alert("Operations are currently not available.\nPlease wait for a while.");
		return 0;
	}
	return 1;
}

function camctrl_ChkMouseDown(X, Y, status) {
	var IndexX;
	var IndexY;
	var id;
	if (disableClick_mode == 1) {
// 		alert("RIGHT CLICK");
		return;
	}
	camctrl_MouseBtn = event.button;
	id = event.srcElement.id;
	for (i = 0; i < PosTbl.length; i++) {
		if (PosTbl[i][4] == id) {
			if ((X >= PosTbl[i][0]) && (X <= PosTbl[i][1]) && (Y >= PosTbl[i][2]) && (Y <= PosTbl[i][3])) {
				camctrl_ZoomStop();
				IndexX = camctrl_RetScopeX(X - PosTbl[i][0]);
				IndexY = camctrl_RetScopeY(Y - PosTbl[i][2]);
				if (camctrl_MouseBtn == 1) {
					camctrl_kind = CtrlKindTbl[i];
				} else if ((camctrl_MouseBtn == 2) && (i == 0)) {
					camctrl_kind = camctrl_SetFocusZoom(IndexX, IndexY);
				}
				break;
			}
		}
	}
	if (camctrl_kind == 1 || camctrl_kind == 8 || camctrl_kind == 9) {
		camctrl_chk_Camstatus(status);
	}
}

function camctrl_MouseDown2(X, Y) {
	var IndexX;
	var IndexY;
	var id;
	if (disableClick_mode == 1) {
		return;
	}
	if (camctrl_kind != 0) {
		return;
	}
	camctrl_MouseBtn = event.button;
	id = event.srcElement.id;
	for (i = 0; i < PosTbl.length; i++) {
		if (PosTbl[i][4] == id) {
			if ((X >= PosTbl[i][0]) && (X <= PosTbl[i][1]) && (Y >= PosTbl[i][2]) && (Y <= PosTbl[i][3])) {
				camctrl_ZoomStop();
				IndexX = camctrl_RetScopeX(X);
				IndexY = camctrl_RetScopeY(Y);
				if (camctrl_MouseBtn == 1) {
					camctrl_kind = CtrlKindTbl[i];
				} else if ((camctrl_MouseBtn == 2) && (i == 0)) {
					camctrl_kind = camctrl_SetFocusZoom2(IndexX, IndexY);
				} else {}
				break;
			}
		}
	}
	switch (camctrl_kind) {
		case gipantilt_case:
			camctrl_pantilt_proc(IndexX, IndexY);
			M.location = camstrURL;
			if (gihttps == 0) {
				camtimer1 = setInterval("camctrl_timctrlpad(camstrURL)", 50);
			} else {
				camtimer1 = setTimeout("camctrl_timctrlpad2(camstrURL)", 500);
			}
			break;
		case gizoom_case:
			camctrl_zoom_proc(IndexY);
			M.location = camstrURL;
			if (gihttps == 0) {
				camtimer1 = setInterval("camctrl_timctrlpad(camstrURL)", 100);
			} else {
				camtimer1 = setTimeout("camctrl_timctrlpad2(camstrURL)", 500);
			}
			break;
		case gifocus_case:
			camctrl_focus_proc(IndexX);
			M.location = camstrURL;
			if (gihttps == 0) {
				camtimer1 = setInterval("camctrl_timctrlpad(camstrURL)", 100);
			} else {
				camtimer1 = setTimeout("camctrl_timctrlpad2(camstrURL)", 500);
			}
			break;
		case gizoom_down_case:
			if (gihttps == 0) {
				camctrl_ChgDirectCtrl('zoom=-4');
				camtimer1 = setInterval("camctrl_timctrl(camstrURL)", 100);
			} else {
				camctrl_ChgDirectCtrl('zoom=-3');
				camtimer1 = setTimeout("camctrl_timctrl2(camstrURL)", 500);
			}
			break;
		case gizoom_up_case:
			if (gihttps == 0) {
				camctrl_ChgDirectCtrl('zoom=4');
				camtimer1 = setInterval("camctrl_timctrl(camstrURL)", 100);
			} else {
				camctrl_ChgDirectCtrl('zoom=3');
				camtimer1 = setTimeout("camctrl_timctrl2(camstrURL)", 500);
			}
			break;
		case gifocus_near_case:
			if (gihttps == 0) {
				camctrl_ChgDirectCtrl('focus=-3');
				camtimer1 = setInterval("camctrl_timctrl(camstrURL)", 100);
			} else {
				camctrl_ChgDirectCtrl('focus=-2');
				camtimer1 = setTimeout("camctrl_timctrl2(camstrURL)", 500);
			}
			break;
		case gifocus_far_case:
			if (gihttps == 0) {
				camctrl_ChgDirectCtrl('focus=3');
				camtimer1 = setInterval("camctrl_timctrl(camstrURL)", 100);
			} else {
				camctrl_ChgDirectCtrl('focus=2');
				camtimer1 = setTimeout("camctrl_timctrl2(camstrURL)", 500);
			}
			break;
		case gibright_down_case:
			camctrl_ChgCamCtrl('bright=down');
			if (gihttps == 0) {
				camtimer1 = setInterval("camctrl_timctrl(camstrURL)", 40);
			} else {
				camtimer1 = setTimeout("camctrl_timctrl2(camstrURL)", 500);
			}
			break;
		case gibright_up_case:
			camctrl_ChgCamCtrl('bright=up');
			if (gihttps == 0) {
				camtimer1 = setInterval("camctrl_timctrl(camstrURL)", 40);
			} else {
				camtimer1 = setTimeout("camctrl_timctrl2(camstrURL)", 500);
			}
			break;
		case 10:
			camctrl_ChgBackFocus('manual=near');
			camtimer1 = setInterval("camctrl_timctrl_bkfocus(camstrURL)", 25);
			break;
		case 11:
			camctrl_ChgBackFocus('manual=far');
			camtimer1 = setInterval("camctrl_timctrl_bkfocus(camstrURL)", 25);
			break;
		default:
			break;
	}
}

function camctrl_SetFocusZoom2(focus, zoom) {
	var GetMovePosi;
	var FocusPosi = Math.abs(16 - focus);
	var ZoomPosi = Math.abs(16 - zoom);
	if (FocusPosi > ZoomPosi) {
		GetMovePosi = CtrlKindTbl[8];
	} else if (FocusPosi < ZoomPosi) {
		GetMovePosi = CtrlKindTbl[7];
	} else {
		GetMovePosi = 0;
	}
	return GetMovePosi;
}

function camctrl_MouseMove2(X, Y) {
	if (camctrl_kind != 0) {
		if ((X >= PosTbl[camctrl_kind - 1][0]) && (X <= PosTbl[camctrl_kind - 1][1]) && (Y >= PosTbl[camctrl_kind - 1][2]) && (Y <= PosTbl[camctrl_kind - 1][3])) {
			camctrl_MouseMoveProc2(X, Y);
		} else {
			camctrl_MouseUp2(X, Y);
		}
	}
}

function camctrl_MouseMoveProc2(X, Y) {
	var IndexX;
	var IndexY;
	IndexX = camctrl_RetScopeX(X);
	IndexY = camctrl_RetScopeY(Y);
	switch (camctrl_kind) {
		case gipantilt_case:
			camctrl_pantilt_proc(IndexX, IndexY);
			break;
		case gizoom_case:
			if (camctrl_kind == camctrl_SetFocusZoom2(IndexX, IndexY)) {
				camctrl_zoom_proc(IndexY);
			} else {
				camctrl_func_stop();
			}
			break;
		case gifocus_case:
			if (camctrl_kind == camctrl_SetFocusZoom2(IndexX, IndexY)) {
				camctrl_focus_proc(IndexX);
			} else {
				camctrl_func_stop();
			}
			break;
		default:
			break;
	}
}

function camctrl_MouseUp2(X, Y) {
	if (camctrl_MouseBtn == event.button) {} else {
		return;
	}
	switch (camctrl_kind) {
		case 0:
			break;
		case gipantilt_case:
		case gizoom_case:
		case gifocus_case:
			camctrl_func_stop();
			camctrl_DisClickTimerStart();
			break;
		case gizoom_down_case:
		case gizoom_up_case:
			if (gihttps == 0) {
				camctrl_ChgDirectCtrl('zoom=0');
				camctrl_TimClear();
				camctrl_DisClickTimerStart();
			} else {
				camstrURL = "/cgi-bin/directctrl?zoom=0&Language=0";
				camctrl_TimClear();
				camctrl_DisClickTimerStart();
			}
			break;
		case gifocus_near_case:
		case gifocus_far_case:
			if (gihttps == 0) {
				camctrl_ChgDirectCtrl('focus=0');
				camctrl_TimClear();
				camctrl_DisClickTimerStart();
			} else {
				camstrURL = "/cgi-bin/directctrl?focus=0&Language=0";
				camctrl_TimClear();
				camctrl_DisClickTimerStart();
			}
			break;
		default:
			camctrl_TimClear();
			camctrl_DisClickTimerStart();
			break;
	}
}

function camctrl_func_stop() {
	if (gihttps == 0) {
		clearInterval(camtimer1);
		switch (camctrl_kind) {
			case gipantilt_case:
				N.location = "/cgi-bin/directctrl?pan=0&tilt=0&Language=0";
				break;
			case gizoom_case:
				N.location = "/cgi-bin/directctrl?zoom=0&Language=0";
				break;
			case gifocus_case:
				N.location = "/cgi-bin/directctrl?focus=0&Language=0";
				break;
			default:
				break;
		}
	} else {
		switch (camctrl_kind) {
			case gipantilt_case:
				camstrURL = "/cgi-bin/directctrl?pan=0&tilt=0&Language=0";
				break;
			case gizoom_case:
				camstrURL = "/cgi-bin/directctrl?zoom=0&Language=0";
				break;
			case gifocus_case:
				camstrURL = "/cgi-bin/directctrl?focus=0&Language=0";
				break;
			default:
				break;
		}
	}
	camtimer_cnt = 0;
	camctrl_kind = 0;
	camctrl_MouseBtn = 0;
}

function camctrl_MouseWheel2(X, Y, Delta) {
	if ("control" == event.srcElement.id) {
		if ((X >= PosTbl[0][0]) && (X <= PosTbl[0][1]) && (Y >= PosTbl[0][2]) && (Y <= PosTbl[0][3])) {
			camctrl_MouseWheelProc(Delta);
		}
	}
}

function camctrl_SendCgiJudge() {
	if (disableClick_mode == 0) {
		return 0;
	}
	return 1;
}

function camctrl_MouseDown3(X, Y, FormInf, afstatus) {
	var id;
	var ret;
	goFormInf = FormInf;
	if (disableClick_mode == 1) {
		return;
	}
	if (camctrl_kind != 0) {
		return;
	}
	camctrl_MouseBtn = event.button;
	id = event.srcElement.id;
	for (i = 0; i < PosTbl.length; i++) {
		if (PosTbl[i][4] == id) {
			if ((X >= PosTbl[i][0]) && (X <= PosTbl[i][1]) && (Y >= PosTbl[i][2]) && (Y <= PosTbl[i][3])) {
				if (camctrl_MouseBtn == 1) {
					camctrl_kind = CtrlKindTbl[i];
					ret = camctrl_chk_Afstatus(afstatus);
					if (ret == 0) {
						return
					}
				} else {}
				break;
			}
		}
	}
	switch (camctrl_kind) {
		case givzoom_times_down_case:
			camctrl_doSubmit_set_vzoom_times('down');
			if (gihttps == 0) {
				camtimer6 = setInterval("camctrl_Vzoom_Times_Timctrl('down')", 100);
			} else {
				camtimer6 = setTimeout("camctrl_Vzoom_Times_Timctrl2('down')", 500);
			}
			break;
		case givzoom_times_up_case:
			camctrl_doSubmit_set_vzoom_times('up');
			if (gihttps == 0) {
				camtimer6 = setInterval("camctrl_Vzoom_Times_Timctrl('up')", 100);
			} else {
				camtimer6 = setTimeout("camctrl_Vzoom_Times_Timctrl2('up')", 500);
			}
			break;
		case gibfocus_near_case:
			camctrl_doSubmit_back_focus_manual('near');
			if (gihttps == 0) {
				camtimer6 = setInterval("camctrl_Back_Focus_Timctrl('near')", 10);
			} else {
				camtimer6 = setTimeout("camctrl_Back_Focus_Timctrl2('near')", 500);
			}
			break;
		case gibfocus_far_case:
			camctrl_doSubmit_back_focus_manual('far');
			if (gihttps == 0) {
				camtimer6 = setInterval("camctrl_Back_Focus_Timctrl('far')", 10);
			} else {
				camtimer6 = setTimeout("camctrl_Back_Focus_Timctrl2('far')", 500);
			}
			break;
		default:
			break;
	}

}

function camctrl_doSubmit_set_vzoom_times(Kind) {
	var objVideo = document.WebVideo;
	goFormInf.times.value = Kind;
	with(goFormInf.form_vzoom_times) {
		method = "post";
		action = "/cgi-bin/set_vzoom?Language=0&Rnd=" + vzstep;
		submit();
		if (Kind == "down") {
			if ((gZoomVal > 320) && (gZoomVal < 350)) {
				vzstep = 308;
				gZoomVal = 320;
			} else if ((gZoomVal <= 100) || (vzstep < 3)) {
				vzstep = 0;
				gZoomVal = 100;
			} else if (gZoomVal >= 350) {
				vzstep--;
				gZoomVal -= 30;
			} else {
				vzstep = vzstep - 3;
				gZoomVal -= 2.1429;
			}
		} else if (Kind == "up") {
			if ((vzstep >= 305) && (vzstep < 308)) {
				vzstep = 308;
				gZoomVal = 320;
			} else if (gZoomVal >= 640) {
				vzstep = 318;
				gZoomVal = 640;
			} else if (gZoomVal >= 320) {
				vzstep++;
				gZoomVal += 30;
			} else {
				vzstep = vzstep + 3;
				gZoomVal += 2.1429;
			}
		} else {
			gZoomVal = 100;
			vzstep = 0;
		}
		if ((gZoomVal > 460) && (gZoomVal < 510)) {
			gZoomVal = 480;
		} else if ((gZoomVal > 440) && (gZoomVal <= 460)) {
			gZoomVal = 440;
		} else if (gZoomVal >= 630) {
			gZoomVal = 640;
		} else if ((gZoomVal < 630) && (gZoomVal > 600)) {
			gZoomVal = 600;
		} else if (gZoomVal <= 100) {
			gZoomVal = 100;
		}
		gViewVal = gZoomVal;
		basisVal = gViewVal;
		ChangeVideo(gViewVal);
		InitSlider();
	}
}

function camctrl_doSubmit_back_focus_manual(Kind) {
	goFormInf.manual.value = Kind;
	with(goFormInf.form_forcus_manual) {
		method = "post";
		action = "/cgi-bin/back_focus?Language=0";
		submit();
	}
}

function camctrl_Vzoom_Times_Timctrl(Kind) {
	camtimer_cnt++;
	if (camtimer_cnt >= 10) {
		camtimer_mode = 1;
		camtimer_cnt = 0;
		camctrl_doSubmit_set_vzoom_times(Kind);
	}
}

function camctrl_Back_Focus_Timctrl(Kind) {
	camtimer_cnt++;
	if (camtimer_cnt >= 10) {
		camtimer_mode = 1;
		camtimer_cnt = 0;
		camctrl_doSubmit_back_focus_manual(Kind);
	}
}

function camctrl_Vzoom_Times_Timctrl2(Kind) {
	camtimer_mode = 1;
	localkind = Kind;
	camctrl_doSubmit_set_vzoom_times(localkind);
	if (camctrl_MouseBtn != 0) {
		camtimer6 = setTimeout("camctrl_Vzoom_Times_Timctrl2(localkind)", 500);
	}
}

function camctrl_Back_Focus_Timctrl2(Kind) {
	camtimer_mode = 1;
	localkind = Kind;
	camctrl_doSubmit_back_focus_manual(localkind);
	if (camctrl_MouseBtn != 0) {
		camtimer6 = setTimeout("camctrl_Back_Focus_Timctrl2(localkind)", 500);
	}
}

function camctrl_MouseUp3(X, Y) {
	if (camctrl_MouseBtn == event.button) {} else {
		return;
	}
	switch (camctrl_kind) {
		case 0:
			break;
		case givzoom_times_down_case:
		case givzoom_times_up_case:
		case gibfocus_near_case:
		case gibfocus_far_case:
		default:
			camctrl_TimClear2();
			camctrl_DisClickTimerStart();
			break;
	}
}

function camctrl_TimClear2() {
	if (gihttps == 0) {
		clearInterval(camtimer6);
	}

	camtimer_cnt = 0;
	camctrl_kind = 0;
	camctrl_MouseBtn = 0;
	camtimer_mode = 0;
}

function camctrl_MouseMove3(X, Y) {
	if (camctrl_kind != 0) {
		if ((X >= PosTbl[camctrl_kind - 1][0]) && (X <= PosTbl[camctrl_kind - 1][1]) && (Y >= PosTbl[camctrl_kind - 1][2]) && (Y <= PosTbl[camctrl_kind - 1][3])) {} else {
			camctrl_MouseUp3(X, Y);
		}
	}
}