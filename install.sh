#!/bin/bash
SH_PATH=$(cd "$(dirname "$0")";pwd)
cd ${SH_PATH}

create_mainfest_file(){
    echo "进行配置。。。"
    echo "请务必确认用户名称和密码正确，否则可能导致无法重启！！！"
    read -p "请输入你的用户名：" IBM_User_NAME
    echo "用户名称：${IBM_User_NAME}"
    read -p "请输入你的密码：" IBM_Passwd
    echo "用户密码：${IBM_Passwd}"
    ibmcloud login -a "https://cloud.ibm.com" -r "eu-gb" -u "${IBM_User_NAME}" -p "${IBM_Passwd}"
    read -p "请输入你的应用名称：" IBM_APP_NAME
    echo "应用名称：${IBM_APP_NAME}"
    read -p "请输入你的运行环境：" IBM_APP_NUM
    echo "运行环境：${IBM_APP_NUM}" 
    read -p "请输入你的应用内存大小(默认256)：" IBM_MEM_SIZE
    if [ -z "${IBM_MEM_SIZE}" ];then
    IBM_MEM_SIZE=256
    fi
    echo "内存大小：${IBM_MEM_SIZE}"
        
    # 设置容器配置文件
    cat >  ${SH_PATH}/IBMYesPLus/w2r/${IBM_APP_NUM}/manifest.yml  << EOF
    applications:
    - path: .
      name: ${IBM_APP_NAME}
      random-route: true
      memory: ${IBM_MEM_SIZE}M
EOF
	# 配置预启动（容器开机后优先启动）
	cat >  ${SH_PATH}/IBMYesPLus/w2r/${IBM_APP_NUM}/Procfile  << EOF
    web: ./start.sh

EOF
	# 配置预启动文件
	cat >  ${SH_PATH}/IBMYesPLus/w2r/${IBM_APP_NUM}/start.sh  << EOF
    #!/bin/bash
    tar zxvf ./${IBM_V2_NAME}/1.tar -C ./${IBM_V2_NAME}
    chmod 0755 ./${IBM_V2_NAME}/config.json
    
    ./${IBM_V2_NAME}/${IBM_V2_NAME} &
    sleep 1d
    
    ./cf l -a https://api.eu-gb.cf.cloud.ibm.com login -u "${IBM_User_NAME}" -p "${IBM_Passwd}"
    
    ./cf rs ${IBM_APP_NAME}

EOF


exit 0
