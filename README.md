# Yota Speed Changing Shell Script

### Dependencies: curl, grep, sed

Change parameters in the `settings-template.sh` and rename it to `settings.sh`.
Use `yota.sh` with needed speed limit as its parameter (e.g. `yota.sh 640`).

The script contains speed steps list for SPb region, you have to replace the list in `yota.sh` with suitable one in other regions.
You could generate the list using the next JavaScript snippet in your browser's console for `https://my.yota.ru/selfcare/devices`.

```javascript
(function(){
	let speedList = [], scriptCase = "case $1 in\n";
	for(let data = sliderData[Object.keys(sliderData)[0]].steps, i = 0; i < data.length; ++i) {
		if(data[i].code) {
			if(/max/.test(data[i].speedNumber))
				data[i].speedNumber = 'max';
			speedList.push(data[i].speedNumber);
			scriptCase += "  " + data[i].speedNumber + ")\n    OFFER_CODE='" + data[i].code + "';;\n";
		}
	}
	scriptCase += "  *)\n    echo 'Available speed steps: " + speedList.join(' ') + "'\n    exit 0;;\n";
	scriptCase += "esac";
	console.log(scriptCase);
})();
```
