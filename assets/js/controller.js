let controller = {
	channel: null,

	init(socket){
		socket.connect()

		let score_indicator = document.getElementById(
			"score-indicator"
		)
		let lives_indicator = document.getElementById(
			"lives-indicator"
		)

		this.channel = socket.channel("web:controller")
		this.channel.join()
			.receive("ok", resp => {
				console.log("Joined successfully", resp)
			})
			.receive("error", resp => {
				console.log("Failed to join channel")
			})

		this.channel.on("score", (resp) => {
			score_indicator.innerHTML = ` ${resp.payload}`
		})

		this.channel.on("position", (resp) => {
			let slider_position = Math.round(resp.payload / 10)
			if(slider_position > 100){
				slider_position = 100
			}
			if(slider_position < 0){
				slider_position = 0
			}

			slider.style.left = `calc(${slider_position}% - 30px)`
		})

		this.channel.on("lives", (resp) => {
			let number_of_lives = resp.payload
			let new_game_indicator = document.getElementById(
				"new-game-indicator"
			)

			if(number_of_lives <= 0){
				lives_indicator.innerHTML = ` 0`
				new_game_indicator.style.visibility = "visible"
			}
			else{
				lives_indicator.innerHTML = ` ${number_of_lives}`
				new_game_indicator.style.visibility = "hidden"
			}
		})

		let slider = document.getElementById(
			"slider-indicator"
		)
		let left_extreme = lives_indicator.getBoundingClientRect()
		left_extreme = left_extreme.left
		let right_extreme = score_indicator.getBoundingClientRect()
		right_extreme = right_extreme.right

		document.onmousemove = (event) => {
			let mouse_position = event.clientX
			let width = right_extreme - left_extreme

			if(mouse_position < left_extreme){
				mouse_position = left_extreme
			}
			if(mouse_position > right_extreme){
				mouse_position = right_extreme
			}

			mouse_position = mouse_position - left_extreme
			mouse_position = (mouse_position / width) * 1000
			mouse_position = Math.floor(mouse_position)

			let payload = {payload: mouse_position}

			this.channel.push("set_position", payload)
		}

		document.onclick = (event) => {
			let number_of_lives = parseInt(
				lives_indicator.innerHTML.trim(), 10
			)

			if(number_of_lives != 0){
				this.channel.push("fire", {payload: null})
			}
			else{
				this.channel.push("new_game", {payload: null})
			}
		}

	},

}

export default controller
