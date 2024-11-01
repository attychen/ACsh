# AutoPush Script
## Overview
#### 这是一个用来批量给镜像打标签、推送到远程仓库的简洁脚本。
#### This is a concise script for batch tagging images and pushing them to a remote repository.


<div style="width:100%;max-width:800px;">
  <img src="https://pic.superbed.cc/item/67249561fa9f77b4dcdb6adc.jpg" alt="autopush.sh" style="max-width: 100%; height: auto;"/>
</div>


## Usage
### English
To use this script, follow these steps:
1. Make the script executable:
   chmod a+x ./AutoPush.sh
2. Run the script with a new tag (optional):
   ./AutoPush.sh [New Tag]
3. The remote repository address defaults to Alibaba Cloud's public address (registry.cn-hangzhou.aliyuncs.com/). If different, replace it manually before execution.
4. Execution logs are stored at:
   ~/autopush/

### Chinese
#### 使用：
1. 使脚本可执行：
   chmod a+x ./AutoPush.sh
2. 运行脚本并指定新标签（可选）：
   ./AutoPush.sh [新标签]
3. 远程仓库地址默认为阿里云公网地址（registry.cn-hangzhou.aliyuncs.com/），若不一致，执行前需手动替换。
4. 执行日志存放路径：
   ~/autopush/

---

## Author
- **AC**  
  - WeChat: attychen
