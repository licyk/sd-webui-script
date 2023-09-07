#/bin/bash

#invokeai启动脚本生成部分
function generate_invokeai_launch()
{
    invokeai_launch_option=$(
        dialog --clear --title "InvokeAI管理" --backtitle "InvokeAI启动参数选项" --ok-label "确认" --cancel-label "取消" --menu "请选择InvokeAI启动参数" 20 60 10 \
        "1" "invokeai-configure" \
        "2" "invokeai" \
        "3" "invokeai --web" \
        "4" "invokeai-ti --gui" \
        "5" "invokeai-merge --gui" \
        "6" "自定义启动参数" \
        "7" "返回" \
        3>&1 1>&2 2>&3 )
    if [ $? = 0 ];then
        if [ "${invokeai_launch_option}" == '1' ]; then 
            invokeai-configure --root ./invokeai
        elif [ "${invokeai_launch_option}" == '2' ]; then 
            invokeai --root ./invokeai
        elif [ "${invokeai_launch_option}" == '3' ]; then 
            invokeai --web --root ./invokeai
        elif [ "${invokeai_launch_option}" == '4' ]; then 
            invokeai-ti --gui --root ./invokeai
        elif [ "${invokeai_launch_option}" == '5' ]; then 
            invokeai-merge --gui --root ./invokeai
        elif [ "${invokeai_launch_option}" == '6' ]; then 
            if [ -f "./term-sd-launch.conf" ];then
                if (dialog --clear --title "InvokeAI管理" --backtitle "InvokeAI启动选项" --yes-label "启动" --no-label "修改参数" --yesno "请选择启动ComfyUI/修改ComfyUI启动参数\n当前启动参数:\ninvokeai $(cat ./term-sd-launch.conf)" 20 60) then
                    invokeai $(cat ./term-sd-launch.conf)
                else
                    generate_invokeai_launch_cust
                    invokeai $(cat ./term-sd-launch.conf)
                fi
            else #找不到启动配置
                generate_invokeai_launch_cust
                invokeai $(cat ./term-sd-launch.conf)
            fi
        elif [ "${invokeai_launch_option}" == '7' ]; then 
            echo
        fi
    fi
}

#invokeai自定义启动参数生成
function generate_invokeai_launch_cust()
{
    cust_invokeai_launch_option=""

    cust_invokeai_launch_option_select=$(
        dialog --clear --title "InvokeAI管理" --backtitle "InvokeAI自定义启动参数选项" --separate-output --notags --ok-label "确认" --no-cancel --checklist "请选择InvokeAI启动参数" 20 60 10 \
        "1" "web" ON \
        "2" "free_gpu_mem" OFF \
        "3" "precision auto" ON \
        "4" "precision fp32" OFF\
        "5" "precision fp16" OFF \
        "6" "no-xformers_enabled" OFF \
        "7" "xformers_enabled" ON \
        "8" "no-patchmatch" OFF \
        "9" "always_use_cpu" OFF \
        "10" "no-esrgan" OFF \
        "11" "no-internet_available" OFF \
        "12" "host" OFF \
        3>&1 1>&2 2>&3)

    if [ $? = 0 ];then
        if [ ! -z "$cust_invokeai_launch_option_select" ]; then
            for cust_invokeai_launch_option_select_ in $cust_invokeai_launch_option_select; do
            case "$cust_invokeai_launch_option_select_" in
            "1")
            cust_invokeai_launch_option="--web $cust_invokeai_launch_option"
            ;;
            "2")
            cust_invokeai_launch_option="--free_gpu_mem $cust_invokeai_launch_option"
            ;;
            "3")
            cust_invokeai_launch_option="--precision auto $cust_invokeai_launch_option"
            ;;
            "4")
            cust_invokeai_launch_option="--precision fp32 $cust_invokeai_launch_option"
            ;;
            "5")
            cust_invokeai_launch_option="--precision fp16 $cust_invokeai_launch_option"
            ;;
            "6")
            cust_invokeai_launch_option="--no-xformers_enabled $cust_invokeai_launch_option"
            ;;
            "7")
            cust_invokeai_launch_option="--xformers_enabled $cust_invokeai_launch_option"
            ;;
            "8")
            cust_invokeai_launch_option="--no-patchmatch $cust_invokeai_launch_option"
            ;;
            "9")
            cust_invokeai_launch_option="--always_use_cpu $cust_invokeai_launch_option"
            ;;
            "10")
            cust_invokeai_launch_option="--no-esrgan $cust_invokeai_launch_option"
            ;;
            "11")
            cust_invokeai_launch_option="--no-internet_available $cust_invokeai_launch_option"
            ;;
            "12")
            cust_invokeai_launch_option="--host 0.0.0.0 $cust_invokeai_launch_option"
            ;;
            *)
            exit 1
            ;;    
            esac
            done

            #生成启动脚本
            if [ -f "./term-sd-launch.conf" ];then
                rm -v ./term-sd-launch.conf
            fi
            echo "设置启动参数 $cust_invokeai_launch_option"
            echo "--root ./invokeai $cust_invokeai_launch_option" > term-sd-launch.conf
        fi
    fi
}