

import { createApp, ref, onMounted, computed, nextTick } from 'vue'
import gsap from 'gsap'

createApp({
	setup() {
		const showVehicleHud = ref(false)
		const showPlayerHud = ref(false)
		const rpm = ref(1.0)
		const gear = ref(0.0)
		const speed = ref(0.0)
		const lightIndicator = ref(0)
		const handbreak = ref(false)
		const abs = ref(false)
		const engine = ref(0)

		const vehicleLocked = ref(false)
		const headlight = ref(false)
		const trunk = ref(false)
		const seatbelt = ref(false)

		const life = ref(100.0)
		const armour = ref(0.0)
		const hunger = ref(0.0)
		const thrist = ref(0.0)
		const stress = ref(0.0)

		const calculateLife = computed(() => (125.0 * (100 - life.value)) / 100.0);
		const calculateArmour = computed(() => (125.0 * (100 - armour.value)) / 100.0);
		const calculateHunger = computed(() => (125.0 * (100 - hunger.value)) / 100.0);
		const calculateThrist = computed(() => (125.0 * (100 - thrist.value)) / 100.0);
		const calculateStress = computed(() => (125.0 * (100 - stress.value)) / 100.0);

		const calculateEngineStatus = computed(() => {
			const e = engine.value;
			if (e >= 800) return 'gray'
			if (e >= 400) return 'orange'
			if (e >= 0) return 'red'
		})

		function SetVehicleData(data){
			const {
				CurrentCarRPM          ,
				CurrentCarGear         ,
				CurrentCarSpeed        ,
				CurrentCarIL           ,
				CurrentCarHandbrake    ,
				CurrentCarABS          ,
				CurrentCarLS_r         ,
				CurrentCarLS_o         ,
				CurrentCarLS_h         ,
				CurrentCarEngineHealth ,
				CurrentCarLocked,
				CurrentCarSeatBelt,
				CurrentCarTrunkOpen
			 } = data;

			 const _rpm  = (CurrentCarRPM * 9 )
			 gsap.to(rpm, { value:_rpm > 9 ? 9.0 : _rpm	 , duration: 0.25, ease: 'power1.in'})
			 gear.value = CurrentCarGear
			 gsap.to(speed, { value: CurrentCarSpeed, duration: 0.3, stagger: 1, snap: { value: 1}, ease: 'power1.out'})

			//  speed.value = CurrentCarSpeed
			 lightIndicator.value = CurrentCarIL
			 handbreak.value = CurrentCarHandbrake
			 abs.value = CurrentCarABS
			 engine.value = CurrentCarEngineHealth
			 vehicleLocked.value = CurrentCarLocked
			 seatbelt.value = CurrentCarSeatBelt
			 trunk.value = CurrentCarTrunkOpen
			 headlight.value = CurrentCarLS_r && (CurrentCarLS_o || CurrentCarLS_h)


		}
		function SetPlayerData(data){
			const {hunger: _hunger, thirst: _thirst, stress: _stress, health, armour: _armour} = data;
			life.value = health;
			armour.value = _armour
			hunger.value = _hunger
			thrist.value = _thirst
			stress.value = _stress
		}


		function onMessage({ data }) {
			if (data.action !== 'HUD_UPDATE') return;

			if (data.ShowPlayerHud && !showPlayerHud.value) showPlayerHud.value = true;
			if (data.ShowVehicleHud && !showVehicleHud.value) showVehicleHud.value = true;

			if (showVehicleHud.value && data.ShowVehicleHud === false) {
				showVehicleHud.value = false;
			}

			if (showVehicleHud.value) {
				SetVehicleData(data);
			}

			if (showPlayerHud.value && data.ShowPlayerHud === false) {
				showPlayerHud.value = false;
			}

			if (showPlayerHud.value) {
				SetPlayerData(data);
			}
		}

		onMounted(() => {
			document.fonts && document.fonts.forEach(function (font) {
				font.loaded.then(function () {
					if (font.family.match(/Oswald-Regular/)) {
						document.gauges.forEach(function (gauge) {
							gauge.update();
						});
					}
				});
			});
			window.addEventListener('message', onMessage)
		})

		onMounted(async () => {
			await nextTick();
			fetch(`https://hud/loaded`, {method: 'POST', body: ""})
		})

		return {
			rpm,
			gear,
			speed,
			lightIndicator,
			handbreak,
			abs,
			engine,
			vehicleLocked,
			headlight,
			trunk,
			seatbelt,
			calculateEngineStatus,
			calculateLife,
			calculateArmour,
			calculateHunger,
			calculateThrist,
			calculateStress,
			showVehicleHud,
			showPlayerHud
		}
	}
}).mount('#app')
