({
	handleChange : function (component, event, helper) {
		var oneField = component.get("v.oneField");
		var newValue;
		var isValid = true;
		if (component.find('email_field')) {
			isValid = component.find('email_field').get("v.validity").valid;
			oneField.isValid = isValid;
		} else if (component.find('tel_field')) {
			var phoneValue = component.find('tel_field').get("v.value");
			var cleaned = ('' + phoneValue).replace(/\D/g, '');
			var match = cleaned.match(/^(\d{3})(\d{3})(\d{4})$/);
			if (match) {
				oneField.value = '(' + match[1] + ') ' + match[2] + '-' + match[3];
			}
			isValid = component.find('tel_field').get("v.validity").valid;
			oneField.isValid = isValid;
		} else if (component.find('url_field')) {
			isValid = component.find('url_field').get("v.validity").valid;
			oneField.isValid = isValid;
		} else if (component.find('date_time_field')) {
			var inputDTField = component.find('date_time_field');
			isValid = inputDTField.get("v.validity").valid;
			oneField.isValid = isValid;
			if (isValid)
				newValue = inputDTField.get("v.value");
			//console.log(newValue);
			oneField.valueDateTime = newValue;
		} else if (component.find('date_field')) {
			var inputDField = component.find('date_field');
			isValid = inputDField.get("v.validity").valid;
			oneField.isValid = isValid;
			if (isValid) {
				newValue = inputDField.get("v.value");
				var newDate = new Date(newValue);
				var timez = newDate.getTimezoneOffset() / 60;
				if (timez < 0) {
					newDate.setDate(newDate.getDate() + 1);
					newDate = newDate.toISOString().split('T')[0];
					newValue = newDate;
				}
				oneField.valueDate = newValue;
			}
		} else if (component.find('textarea_field')) {
			newValue = component.find('textarea_field').get("v.value");
			//console.log(newValue);
			oneField.value = newValue;
		}
		//console.log('isValid ',isValid);
		if (isValid) {
			oneField.wasUpdated = true;
		}
		component.set("v.oneField",oneField);
	}
})