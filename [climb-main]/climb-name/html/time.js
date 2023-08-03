const TimeAndDate = document.getElementById('TimeAndDate')

window.addEventListener('message', (event) => {
	let data = event.data
	if(data.action == 'setTimeAndDate') {
		TimeAndDate.innerText = data.time
	}
})