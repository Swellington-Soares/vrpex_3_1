var lastRadio = "Offline"
var voice = "Normal"

let currentValue = 0; // valor inicial

// Função para atualizar a velocidade de forma suave
function updateSpeed(newSpeed) {
    gsap.to({ value: currentValue }, {
        value: newSpeed,
        duration: 0.5, // duração da animação em segundos
        roundProps: "value", // arredonda o valor para números inteiros
        onUpdate: function () {
            $('.mileage-frame p').html(`${this.targets()[0].value.toString().padStart(3, "0")}`);
        },
        onComplete: function () {
            // Atualiza o valor atual quando a animação termina
            currentValue = newSpeed;
        }
    });
}

function minimalTimers(Seconds) {
    var Days = Math.floor(Seconds / 86400)
    Seconds = Seconds - Days * 86400
    var Hours = Math.floor(Seconds / 3600)
    Seconds = Seconds - Hours * 3600
    var Minutes = Math.floor(Seconds / 60)
    Seconds = Seconds - Minutes * 60

    const [D, H, M, S] = [Days, Hours, Minutes, Seconds].map(s => s.toString().padStart(2, 0))

    if (Days > 0) {
        return D + ":" + H
    } else if (Hours > 0) {
        return H + ":" + M
    } else if (Minutes > 0) {
        return M + ":" + S
    } else if (Seconds > 0) {
        return "00:" + S
    }
}

$(function () {
    window.addEventListener("message", function (event) {

        var item = event.data

        if (item.street) $("#rua").html(item.street);
        
        
        
        $("#perolas").html(item.coins);
        if (item.hour && item.minute) {
            let hour = item.hour
            let minute = item.minute

            if (hour < 10) {
                hour = "0" + hour
            }

            if (minute < 10) {
                minute = "0" + minute
            }

            $("#horas").html(hour + ":" + minute);
        }

        if (event["data"]["safezone"] !== undefined) {
            if (event["data"]["safezone"] == true) {
                $("#safezone").fadeIn(500);
            } else {
                $("#safezone").fadeOut(500);
            }

            return
        }

        if (item.isArmed) {
            $(".bullets span").html(`${item.inClipAmmo}<b>/${item.totalAmmo}</b>`)
            $(".bullets").show()
        } else {
            $(".bullets").hide()
        }
    
        if (item.health <= 1) {
            setCircle("0", 'lifeFill')
        } else {
            setCircle(item.health, 'lifeFill')
        }

        if (item.armour <= 0) {
            setCircle("0", 'ArmourFill')
        } else {
            setCircle(item.armour, 'ArmourFill')
        }

        if (event["data"]["thirst"] !== undefined) {
            setCircle(item.thirst, 'sedeFill')
        }

        if (event["data"]["hunger"] !== undefined) {
            setCircle(item.hunger, 'HungerFill')
        }

        if (event["data"]["stress"] !== undefined) {
            setCircle(item.stress, 'stressFill')
        }

        if (event["data"]["voice"] !== undefined) {            
            voice = event["data"]["voice"]
            $("#voice").html(voice)
        }

        if (item.talking !== undefined) {
            if (item.talking == 1) {
                $("#voice").html("<active>" + voice + "</active>");
            } else {
                $("#voice").html("<inative>" + voice + "</inative>");
            }
        }

        if (item.radio !== undefined) {            
            $("#radio").html(item.radio);
        }

        if (event.data.hud !== undefined) {
            if (event["data"]["hud"]) {
                $("#displayHud").fadeIn(500);
            } else {
                $("#displayHud").fadeOut(500);
            }
            return;
        }

        if (event.data.vehicle !== undefined) {
            if (event["data"]["vehicle"]) {


                $("#car-container").css("display", "block");

                $('#rpm').css({ strokeDasharray: (((item.rpm * 100) * 30) / 100) + 31 + 'rem' });
                $('#fuel').css({ strokeDasharray: 9 + (item.fuel * 7.5) / 100 + 'rem' });
                const porcent = getPorcent(item.nitro, 2000);

                $('#nitro').css({ strokeDasharray: 9 + (porcent * 7.5) / 100 + 'rem' });


                if (item.belt == true) {
                    $(".Seatbelt").addClass("Green").removeClass("Gray");
                } else {
                    $(".Seatbelt").addClass("Gray").removeClass("Green");
                }

                if (item.healthcar >= 501) {
                    $(".HealthCar").addClass("Gray").removeClass("Yellow").removeClass("Red");
                } else if (item.healthcar <= 500 && item.healthcar >= 200) {
                    $(".HealthCar").addClass("Yellow").removeClass("Gray").removeClass("Red");
                } else if (item.healthcar <= 200) {
                    $(".HealthCar").addClass("Red").removeClass("Gray").removeClass("Yellow");
                }

                if (item.pneus == 0) {
                    $(".Tyres").addClass("Gray").removeClass("Yellow").removeClass("Red");
                } else if (item.pneus == 1) {
                    $(".Tyres").addClass("Yellow").removeClass("Gray").removeClass("Red");
                } else if (item.pneus >= 2) {
                    $(".Tyres").addClass("Red").removeClass("Gray").removeClass("Yellow");
                }

                if (item.VHeadlight == false) {
                    $(".Headlight").addClass("Gray").removeClass("Blue");
                } else {
                    $(".Headlight").addClass("Blue").removeClass("Gray");
                }

                if (item.locked == true) {
                    $(".Locked").addClass("Gray").removeClass("Green");
                } else {
                    $(".Locked").addClass("Green").removeClass("Gray");
                }

                // if (item.speed < 9) return $('.mileage-frame p').html('<span>00</span>' + item.speed.toFixed(0));
                // if (item.speed < 99) return $('.mileage-frame p').html('<span>0</span>' + item.speed.toFixed(0));
                // $('.mileage-frame p').html(item.speed.toFixed(0));
                updateSpeed(item.speed);
            } else {
                $("#car-container").css("display", "none");
            }            
        }
    });
});

function setProgressSpeed(value, element) {
    var circle = document.querySelector(element);
    var radius = circle.r.baseVal.value;
    var circumference = radius * 2 * Math.PI;
    var percent = value * 100 / 220;

    circle.style.strokeDasharray = `${circumference} ${circumference}`;
    circle.style.strokeDashoffset = `${circumference}`;
    const offset = circumference - ((-percent * 73) / 100) / 100 * circumference;
    circle.style.strokeDashoffset = -offset;
}

function setCircle(percentage, fillClass) {
    let circle = document.querySelector(`.${fillClass}`)
    let calc = (125 * (100 - percentage)) / 100
    circle.style.strokeDashoffset = calc
}

const getPorcent = (value = 0, maxValue = 0) => {
    return (value * 100) / maxValue;
}