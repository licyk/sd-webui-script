#!/bin/bash

#python依赖库版本备份与恢复功能
function python_package_ver_backup_or_restore()
{
    #如果没有存放备份文件的文件夹时就创建一个新的
    if [ ! -d "./term-sd-python-pkg-backup" ];then
        mkdir term-sd-python-pkg-backup
    fi

    enter_venv
    python_package_ver_backup_or_restore_dialog=$(dialog --clear --title "Term-SD" --backtitle "依赖库版本管理选项" --ok-label "确认" --cancel-label "取消" --menu "请选择Term-SD的依赖库版本管理功能\n当前"$term_sd_manager_info"依赖库版本备份情况:$( [ ! -z "$(ls ./term-sd-python-pkg-backup)" ] && echo \\n$( ls -lrh ./term-sd-python-pkg-backup --time-style=+"%Y-%m-%d" | awk 'NR==2 {print $7}' ) || echo "无" )" 25 70 10 \
        "1" "备份python依赖库版本" \
        "2" "python依赖库版本管理" \
        "3" "返回" \
        3>&1 1>&2 2>&3)

    if [ $? = 0 ];then
        if [ $python_package_ver_backup_or_restore_dialog = 1 ];then
            if (dialog --clear --title "Term-SD" --backtitle "依赖库版本备份选项" --yes-label "是" --no-label "否" --yesno "是否备份"$term_sd_manager_info"依赖库?" 25 70) then
                backup_python_package_ver
            fi
            python_package_ver_backup_or_restore
        elif [ $python_package_ver_backup_or_restore_dialog = 2 ];then
            python_package_ver_backup_list
            python_package_ver_backup_or_restore
        elif [ $python_package_ver_backup_or_restore_dialog = 3 ];then
            exit_venv
        fi
    else
        exit_venv
    fi
}

#python依赖库备份功能
function backup_python_package_ver()
{
    term_sd_notice "备份python依赖库版本中"
    #生成一个文件名
    python_package_ver_backup_list_file_name=$(echo requirements-bak-$(date "+%Y-%m-%d-%H-%M-%S").txt)

    #将python依赖库中各个包和包版本备份到文件中
    pip_cmd freeze > ./term-sd-python-pkg-backup/$python_package_ver_backup_list_file_name
    term_sd_notice "备份完成"
}

#备份文件列表展示
function python_package_ver_backup_list()
{
    python_package_ver_backup_list_dialog=$(dialog --clear --title "Term-SD" --backtitle "依赖库版本记录列表选项" --ok-label "确认" --cancel-label "取消" --menu "请选择依赖库版本记录" 25 70 10 \
        "-->返回<--" "<---" \
        $(ls -lrh "./term-sd-python-pkg-backup" --time-style=+"%Y-%m-%d" | awk '{ print $7 " " $5 }') \
        3>&1 1>&2 2>&3)

    if [ $? = 0 ];then
        if [ $python_package_ver_backup_list_dialog = "-->返回<--" ];then
            echo
        elif [ -f "./term-sd-python-pkg-backup/$python_package_ver_backup_list_dialog" ];then
            process_python_package_ver_backup_file
            python_package_ver_backup_list
        elif [ -d "./term-sd-python-pkg-backup/$python_package_ver_backup_list_dialog" ];then
            python_package_ver_backup_list
        else
            python_package_ver_backup_list
        fi
    fi
}

#依赖库备份文件处理选项
function process_python_package_ver_backup_file()
{
    process_python_package_ver_backup_file_dialog=$(dialog --clear --title "Term-SD" --backtitle "依赖库版本记录管理选项" --ok-label "确认" --cancel-label "取消" --menu "请选择Term-SD的依赖库版本记录管理功能\n当前版本记录:\n$(echo $python_package_ver_backup_list_dialog | awk '{sub(".txt","")}1')" 25 70 10 \
        "1" "恢复该版本记录" \
        "2" "删除该版本记录" \
        "3" "返回" \
        3>&1 1>&2 2>&3)

    if [ $? = 0 ];then
        if [ $process_python_package_ver_backup_file_dialog = 1 ];then
            if (dialog --clear --title "Term-SD" --backtitle "依赖库版本恢复确认选项" --yes-label "是" --no-label "否" --yesno "是否恢复该版本记录?" 25 70) then
                restore_python_package_ver
            fi
            process_python_package_ver_backup_file
        elif [ $process_python_package_ver_backup_file_dialog = 2 ];then
            if (dialog --clear --title "Term-SD" --backtitle "安装确认选项" --yes-label "是" --no-label "否" --yesno "是否删除该版本记录?" 25 70) then
                term_sd_notice "删除$(echo $python_package_ver_backup_list_dialog | awk '{sub(".txt","")}1')记录中"
                rm -rf ./term-sd-python-pkg-backup/$python_package_ver_backup_list_dialog
            fi
        fi
    fi
}

#恢复依赖库版本功能
function restore_python_package_ver()
{
    #安装前准备
    proxy_option #代理选择
    pip_install_methon #安装方式选择
    final_install_check #安装前确认

    if [ $final_install_check_exec = 0 ];then
        print_line_to_shell "python软件包版本恢复"
        term_sd_notice "开始恢复依赖库版本中,版本$(echo $python_package_ver_backup_list_dialog | awk '{sub(".txt","")}1')"

        #这里不要用"",不然会出问题
        cat ./term-sd-python-pkg-backup/$python_package_ver_backup_list_dialog | awk -F'==' '{print $1}' > tmp-python-pkg-no-vers-bak.txt #生成一份无版本的备份列表
        pip_cmd freeze | awk -F'==' '{print $1}' > tmp-python-pkg-no-vers.txt #生成一份无版本的现有列表

        #生成一份软件包卸载名单
        for python_package_need_to_remove in $(cat ./tmp-python-pkg-no-vers-bak.txt); do
            sed -i '/'$python_package_need_to_remove'/d' ./tmp-python-pkg-no-vers.txt 2> /dev/null #需要卸载的依赖包名单
        done

        tmp_disable_proxy #临时取消代理,避免一些不必要的网络减速
        if [ ! -z "$(cat ./tmp-python-pkg-no-vers.txt)" ];then
            print_line_to_shell "python软件包卸载列表"
            term_sd_notice "将要卸载以下python软件包"
            cat ./tmp-python-pkg-no-vers.txt
            print_line_to_shell
            term_sd_notice "卸载多余软件包中"
            pip_cmd uninstall -y -r ./tmp-python-pkg-no-vers.txt  #卸载名单中的依赖包
        fi
        rm -rf tmp-python-pkg-no-vers.txt #删除卸载名单列表
        rm -rf tmp-python-pkg-no-vers-bak.txt #删除不需要的包名文件缓存
        print_line_to_shell "python软件包安装列表"
        term_sd_notice "将要安装以下python软件包"
        cat ./term-sd-python-pkg-backup/$python_package_ver_backup_list_dialog
        print_line_to_shell
        term_sd_notice "恢复依赖库版本中"
        pip_cmd install -r ./term-sd-python-pkg-backup/$python_package_ver_backup_list_dialog --prefer-binary --default-timeout=100 --retries 5 #安装原有版本的依赖包
        tmp_enable_proxy #恢复原有的代理
        term_sd_notice "恢复依赖库版本完成"
        print_line_to_shell
    fi
}