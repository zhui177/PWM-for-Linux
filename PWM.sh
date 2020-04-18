#!/bin/bash
if [ $# -gt 1 ]; then
    echo "Too many parameters."
    exit 1
fi
type intel_reg > /dev/null 2>&1
if [ $? -eq 1 ];then
    sudo apt-get install intel-gpu-tools -y
fi
type intel_reg > /dev/null 2>&1
if [ $? -eq 1 ];then
    echo "intel-gpu-tools安装失败！请自行安装。"
    exit
fi
string1=`sudo intel_reg read 0xC6204`
string2=`sudo intel_reg read 0xC8254`
i=1
while((1==1))
do
    splitchar1=`echo $string1 | cut -d " " -f $i`
    if [ "$splitchar1" != "(0x000c6204):" ]; then
        ((i++))
    else
        ((i++))
        ((clock=`echo $string1 | cut -d " " -f $i`))
        break
    fi
done
if [ $# -eq 0 ]; then
    j=1
    while((1==1))
    do
        splitchar2=`echo $string2 | cut -d " " -f $j`
        if [ "$splitchar2" != "(0x000c8254):" ]; then
            ((j++))
        else
            ((j++))
            ((initialFreq=`echo $string2 | cut -d " " -f $j`))
            break
        fi
    done
    initialfreq=`expr $clock \* 1000000 \* 65537 / 128 / $initialFreq`
    echo "当前PWM频率为：$initialfreq"
elif [ $# -eq 1 ]; then
    targetfreq=$1
    result=`expr $clock \* 65537 \* 1000000 / 128 / $targetfreq`
    Result=`echo "obase=16;$result"|bc`
    sudo intel_reg write 0xC8254 $Result
fi
