function showCoords(element,event) {
	var cX = event.clientX;
	var cY = event.clientY;
	var eid = event.target.id
	var coords1 = "client - X: " + cX + ", Y coords: " + cY;
	
	if ( (eid.indexOf("field") >= 0) || (eid.indexOf("roost") >= 0) ) {
		document.getElementById("output02").innerHTML = eid +": "+ coords1 +" - CLEAR!"
	} else {
		document.getElementById("output02").innerHTML = eid +": "+ coords1 +" - AVOID!"
	}
}


function checkNextStep(nodeID,nextX,nextY,targetX,targetY) {

	document.title = bT;

	if ( (nextX != targetX) & (nextY != targetY) & (bT.indexOf("field") >= 0) ) {
		return true;
	} else {
		return false;
	}
}

function moveNode(burgler) {

	nextX = 0;
	nextY = 0;
	
	safeMove = checkNextStep(nodeID,nextX,nextY,bX,bY);

	if ( safeMove == true ) {
		nodeID.style.top = bY +"px";
		nodeID.style.left = bX +"px";
		exit();
	}
	exit();
// 	window.alert("X: "+ bX +" - "+ nX +" || Y: "+ bY +" - "+ nY);

	if (bX > nX) { nextX = nX + stepSize; }
	if (bY > nY) { nextY = nY - stepSize; }

	nextX = (bX - nX) + stepSize;
	nextY = (bY - nY) + stepSize;

	safeMove = checkNextStep(nodeID,nextX,nextY,bX,bY);

	if ( safeMove == true ) {
// 		window.alert("X: "+ nextX +" - Y: "+ nextY);
		nodeID.style.top = nextY;
		nodeID.style.left = nextX;

		nextX = null;
		nextY = null;

		gatherNode();
		updateOutput();
		
		safeMove = false;

// 		setTimeout(moveNode(burgler), 5000);
	}


}


function gatherNode() {

	nodeID = document.getElementById("node01");
	nRect = nodeID.getBoundingClientRect();

	nX = nRect.left;
	nY = nRect.top;
	nW = nRect.width;
	nH = nRect.height;
}

function gatherRoost() {
	
	roostID = document.getElementById("roost01");
	rRect = roostID.getBoundingClientRect();


	rX = rRect.left;
	rY = rRect.top;
	rW = rRect.width;
	rH = rRect.height;
}


function updateOutput() {

	output.innerHTML = "Roost Top: "+ rY +" || Node Top: "+ nY +"<BR>";
	output.innerHTML += "Roost Left: "+ rX +" || Node Left: "+ nX +"<BR>";
	output.innerHTML += "Roost Width: "+ rW +" || Node Width: "+ nW +"<BR>";
	output.innerHTML += "Roost Height: "+ rH +" || Node Height: "+ nH +"<BR>";
// 	output.innerHTML += "---------<BR>";
}

function setNodes() {

	gatherRoost();
	gatherNode();

	output = document.getElementById("output01");
	
	stepSize = 10;
	
	safeMove = false;

	nodeID.style.top = (rRect.top + ((rRect.height / 2) - (nRect.height / 2)));
	nodeID.style.left = (rRect.left + ((rRect.width / 2) - (nRect.width / 2)));
	
	gatherNode()
	updateOutput()
}


function goHere(element,event) {

	burgler = event;
	bX = burgler.clientX;
	bY = burgler.clientY;
	bT = burgler.target.id;

	var coords1 = bT +" - client - X: " + bX + ", Y coords: " + bY;
	var outputClick = document.getElementById("output03").innerHTML

	document.getElementById("output03").innerHTML = "BURGLER: "+ coords1

	moveNode(burgler)
}




