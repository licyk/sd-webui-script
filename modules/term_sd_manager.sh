#!/bin/bash

#主界面
function mainmenu()
{
    export term_sd_manager_info=""
    cd "$start_path" #回到最初路径
    exit_venv #确保进行下一步操作前已退出其他虚拟环境
    mainmenu_=$(
        dialog --clear --title "Term-SD" --backtitle "主界面" --ok-label "确认" --cancel-label "取消" --menu "请选择Term-SD的功能\n当前虚拟环境状态:$([ $venv_active = 0 ] && echo "启用" || echo "禁用")\n当前代理设置:$([ -z $http_proxy ] && echo "无" || echo $http_proxy)" 23 70 12 \
        "0" "Term-SD更新管理" \
        "1" "AUTOMATIC1111-stable-diffusion-webui管理" \
        "2" "ComfyUI管理" \
        "3" "InvokeAI管理" \
        "4" "lora-scripts管理" \
        "5" "venv虚拟环境设置" \
        "6" "pip镜像源设置" \
        "7" "pip缓存清理" \
        "8" "代理设置" \
        "9" "空间占用分析" \
        "10" "帮助" \
        "11" "退出" \
        3>&1 1>&2 2>&3 )

    if [ $? = 0  ];then #选择确认
        if [ $mainmenu_ = 0 ]; then #选择Term-SD更新
            term_sd_update_option
        elif [ $mainmenu_ = 1 ]; then #选择AUTOMATIC1111-stable-diffusion-webui
            a1111_sd_webui_option
        elif [ $mainmenu_ = 2 ]; then #选择ComfyUI
            comfyui_option
        elif [ $mainmenu_ = 3 ]; then #选择InvokeAI
            invokeai_option
        elif [ $mainmenu_ = 4 ]; then #选择lora-scripts
            lora_scripts_option
        elif [ $mainmenu_ = 5 ]; then #选择venv虚拟环境配置
            venv_option
        elif [ $mainmenu_ = 6 ]; then #选择pip镜像源
            set_pip_mirrors_option
        elif [ $mainmenu_ = 7 ]; then #选择pip缓存清理
            pip_cache_clean
        elif [ $mainmenu_ == 8 ]; then #选择代理选项
            set_proxy_option
        elif [ $mainmenu_ = 9 ]; then #选择代理选项
            disk_space_stat
        elif [ $mainmenu_ = 10 ]; then #选择帮助
            help_option
        elif [ $mainmenu_ = 11 ]; then #选择退出
            print_line_to_shell
            echo "退出Term-SD"
            exit 1
        fi
    else #选择取消
        print_line_to_shell
        echo "退出Term-SD"
        exit 1
    fi
}

#启动项目功能
function term_sd_launch()
{
    print_word_to_shell="$term_sd_manager_info 启动"
    print_line_to_shell
    enter_venv
    $python_cmd $(cat ./term-sd-launch.conf)
    print_line_to_shell
}

#项目更新失败修复功能
function term_sd_fix_pointer_offset()
{
    git checkout $(git branch -a | grep HEAD | awk -F'/' '{print $NF}') #查询当前主分支并重新切换过去
    git reset --hard HEAD #回退版本,解决git pull异常
}

#显示版本信息
function term_sd_version()
{
    dialog --clear --title "Term-SD" --backtitle "Term-SD开始界面" --ok-label "确认" --msgbox "版本信息:\n\n
系统:$(uname -o) \n
Term-SD:"$term_sd_version_" \n
python:$($python_cmd --version | awk 'NR==1'| awk -F  ' ' ' {print  " " $2} ') \n
pip:$(pip --version | awk 'NR==1'| awk -F  ' ' ' {print  " " $2} ') \n
aria2:$(aria2c --version | awk 'NR==1'| awk -F  ' ' ' {print  " " $3} ') \n
git:$(git --version | awk 'NR==1'| awk -F  ' ' ' {print  " " $3} ') \n
dialog:$(dialog --version | awk 'NR==1'| awk -F  ' ' ' {print  " " $2} ') \n
\n
提示: \n
使用方向键、Tab键移动光标,方向键翻页(鼠标滚轮无法翻页),Enter进行选择,Space键勾选或取消勾选,(已勾选时显示[*]),Ctrl+Shift+V粘贴文本,Ctrl+C可中断指令的运行,鼠标左键可点击按钮(右键无效)\n
第一次使用Term-SD时先在主界面选择“帮助”查看使用说明,参数说明和注意的地方,内容不定期更新" 23 70
    mainmenu
}