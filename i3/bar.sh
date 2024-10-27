#!/bin/bash

while :
do
    # time 
    current_datetime=$(date '+%m/%d/%y %H:%M:%S')

    # CPU usage using mpstat
    cpu_usage=$(mpstat 1 1 | awk '/Average:/ {print int(100 - $NF)}')

    # GPU usage (NVIDIA)
    gpu_usage=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)

    # CPU temperatures
    core_temps=$(sensors | grep 'Core ' | awk '{print $3}' | tr -d '+°C')
    total_temp=0
    count=0

    for temp in $core_temps; do
        # Check if temp is a valid number
        if [[ $temp =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
            total_temp=$(echo "$total_temp + $temp" | bc)
            count=$((count + 1))
        fi
    done

    # Calculate average CPU temperature
    if [ $count -gt 0 ]; then
        avg_cpu_temp=$(echo "scale=2; $total_temp / $count" | bc)
    else
        avg_cpu_temp="N/A"
    fi

    # GPU temperature (NVIDIA)
    gpu_temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits)

    # RAM usage
    mem_info=$(free | awk '/Mem:/ {print int($3/$2 * 100)}')

    # Battery status
    battery_percentage=$(acpi -b | grep -oP '\d+(?=%)')

    # CPU fan speed
    cpu_fan=$(sensors | grep 'cpu_fan:' | awk '{print $2}')

    echo "${current_datetime} | CPU: ${cpu_usage}% | GPU: ${gpu_usage}% | CPU Temp: ${avg_cpu_temp}°C | GPU Temp: ${gpu_temp}°C | RAM: ${mem_info}% | Fans: ${cpu_fan} RPM | Battery: ${battery_percentage}%"
    sleep 2

done
