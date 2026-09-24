#!/bin/sh

h=$(date +%H)

case "$h" in
    05|06)
        msgs="
Bro... you are awake at THIS hour?
The sun is barely awake. Why are you?
Sleep schedule: completely fucked."
        ;;

    07|08)
        msgs="
Morning mf. Try not to waste today.
The day has started. Your excuses have not.
Wake up. The world is not waiting."
        ;;

    09|10)
        msgs="
Good morning. Go do something useful.
Another day, another questionable decision.
Your terminal misses you."
        ;;

    11|12)
        msgs="
Still alive? That is something.
Half the day is gone already.
Your productivity is suspiciously quiet."
        ;;

    13|14)
        msgs="
It is afternoon. Your productivity is missing.
Lunch is over. Now pretend to work.
Bro, what exactly have you done today?"
        ;;

    15|16)
        msgs="
Wtf are you doing? Go read something.
Open the book. Not another browser tab.
Still procrastinating? Impressive consistency."
        ;;

    17|18)
        msgs="
Evening already. Time to pretend you worked.
The day is almost gone. Nice work doing nothing.
Go outside before the sun completely gives up."
        ;;

    19|20)
        msgs="
Hey mf. It is evening. Just puff and chill.
Evening mode: activated.
You survived another day. Barely."
        ;;

    21|22)
        msgs="
Night shift again? Go read a fucking book.
Your laptop remembers your productivity. It is not impressed.
Hyprland is running. Your life should be too."
        ;;

    23)
        msgs="
I thought you dont sleep at night.
Midnight already? Of course.
Another night sacrificed to absolutely nothing."
        ;;

    00|01)
        msgs="
Midnight. Excellent time to ruin tomorrow.
Bro, sleep exists for a reason.
Tomorrow-you is already disappointed."
        ;;

    02|03)
        msgs="
Bro... sleep. Seriously.
2 AM and you are still here?
Sleep is free. You should try it."
        ;;

    04)
        msgs="
4 AM? You are becoming a nocturnal animal.
Bro, what the fuck are you doing?
At this point even the birds are judging you."
        ;;
esac

printf '%s\n' "$msgs" | sed '/^[[:space:]]*$/d' | shuf -n 1
