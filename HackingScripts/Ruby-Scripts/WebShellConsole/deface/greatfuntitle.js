			var left=""; 
			var right=""; 
			var msg="IDSYSTEM404 WAS HERE!"; 
			var speed=500; 

			function scroll_title() { 
				document.title=left+msg+right; 
				msg=msg.substring(1,msg.length)+msg.charAt(0); 
				setTimeout("scroll_title()",speed); 
				} 
				scroll_title(); 