#!/bin/sh
##################################################################################
#    This file is part of System Monitor Gnome extension.
#    System Monitor Gnome extension is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#    System Monitor Gnome extension is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#    You should have received a copy of the GNU General Public License
#    along with System Monitor.  If not, see <http://www.gnu.org/licenses/>.
#    Copyright 2017 Fran Glais, David King, indigohedgehog@github.
##################################################################################

##################################
#                                #
#   Check for GPU memory usage   #
#                                #
##################################

checkcommand()
{
	command -v "$1" > /dev/null 2>&1
}

# This will print three lines. The first one is the the total vRAM available,
# the second one is the used vRAM and the third on is the GPU usage in %.
if checkcommand nvidia-smi; then
	nvidia-smi -i 0 --query-gpu=memory.total,memory.used,utilization.gpu --format=csv,noheader,nounits | while IFS=', ' read -r a b c; do
		echo "$a
$b
$c"; done
elif checkcommand glxinfo; then
	TOTALVRAM=$(glxinfo | grep -A2 -i GL_NVX_gpu_memory_info | grep -E -i "dedicated" | cut -f2- -d ':' | gawk '{print $1}')
	AVAILVRAM=$(glxinfo | grep -A4 -i GL_NVX_gpu_memory_info | grep -E -i "available dedicated" | cut -f2- -d ':' | gawk '{print $1}')
	FREEVRAM=$((TOTALVRAM-AVAILVRAM))
	echo "$TOTALVRAM"
	echo "$FREEVRAM"
elif checkcommand /opt/rocm/bin/rocm-smi; then
    sdir=$(pwd)
    cd /opt/rocm/bin/
    python -c "import rocm_smi as smi; devices=smi.listDevices(True); mem=smi.getMemInfo(devices[0], 'vram'); usage=smi.getSysfsValue(devices[0], 'use'); print(str(int(mem[1])/(1024**2))+'\n'+str(int(mem[0])/(1024**2))+'\n'+usage)"
    cd $sdir
fi
