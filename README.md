<!-- omit in toc -->
# Ansible Test

[https://github.com/gakimaru-on-connext/testansible](https://github.com/gakimaru-on-connext/testansible)

---
- [■概要](#概要)
- [■動作要件](#動作要件)
- [■VM 操作方法](#vm-操作方法)
- [■Ansible プロビジョニング準備](#ansible-プロビジョニング準備)
- [■Ansible プロビジョニング実行](#ansible-プロビジョニング実行)
- [■セットアップ内容](#セットアップ内容)
- [■各サーバーへのアクセス方法](#各サーバーへのアクセス方法)
- [■解説：Vagrant 設定](#解説vagrant-設定)
- [■解説：プロビジョニング](#解説プロビジョニング)
- [■解説：複数 VM の起動とプロビジョニング](#解説複数-vm-の起動とプロビジョニング)
- [■ディレクトリ構成](#ディレクトリ構成)

---
## ■概要

- Vagrant を用いた VM 上へのOSセットアップのテスト
- Ansible によるセットアップを行う
  - 本場環境のプロビジョニングを想定して、複数の VM に対する同時セットアップにも対応（コメントアウト状態）
- シェル（スクリプト）によるセットアップと比較するためのリポジトリも用意
  - [https://github.com/gakimaru-on-connext/testvagrant](https://github.com/gakimaru-on-connext/testvagrant)

---
## ■動作要件

- macOS ※x86系のみ

- Oracle Virtualbox

  - https://www.oracle.com/jp/virtualization/technologies/vm/downloads/virtualbox-downloads.html

- Vagrant

  ```shell
  $ brew install vagrant
  ```

- Python3

  ```shell
  $ brew install python3
  ```

- Ansible

  ```shell
  $ brew install ansible
  ```

---
## ■VM 操作方法

- [testvagrant](https://github.com/gakimaru-on-connext/testvagrant#vm-%E6%93%8D%E4%BD%9C%E6%96%B9%E6%B3%95) 参照

---
## ■Ansible プロビジョニング準備

<!-- omit in toc -->
### ▼インベントリファイルを生成

```shell
$ cd ansible
$ bash inventories_setup.sh
```

<!-- omit in toc -->
### ▼インベントリファイルを検証

```shell
$ cd ansible
$ bash inventories_verify.sh
```

<!-- omit in toc -->
### ▼インベントリファイルの内容確認

```shell
$ cd ansible
$ bash inventories_verify.sh --ilst
```

または

```shell
$ bash inventories_verify.sh --graph
```

または

```shell
$ bash inventories_verify.sh --yaml
```

冗長出力

```shell
$ bash inventories_verify.sh --list -vvv
```

<!-- omit in toc -->
### ▼Playbook の内容・書き方エラーチェック

```shell
$ cd ansible
$ bash ansible_lint.sh
```

- ansible_lint_result.txt が出力される

---
## ■Ansible プロビジョニング実行

<!-- omit in toc -->
### ▼[方法1] 直接 ansible-playbook コマンドを実行してプロビジョニング

```shell
$ cd ansible/playbook
$ ansible-playbook -i inventories/vagrant_hosts.yml site_all_setup.yml
```

<!-- omit in toc -->
### ▼[方法2] vagrant から ansible-playbook コマンドを実行してプロビジョニング

```shell
$ cd vagrant
$ vagrant provision
```

- Vagrantfile 内で [方法1] と同様のコマンドが実行されるように設定されている

  - Vagrantfile

    ```ruby
    config.vm.provision :ansible do |ansible|
      playbook_dir = "../ansible/playbook"
      ansible.config_file = playbook_dir + "/ansible.cfg"
      ansible.playbook = playbook_dir + "/site_all_setup.yml"
      ansible.inventory_path = playbook_dir + "/inventories/vagrant_hosts.yml"
      ansible.limit = 'all'
      #ansible.verbose = "vvv"
      #ansible.tags = "tag1,tag2,..."
      #ansible.tags = "os,mariadb"
    end
    ```

<!-- omit in toc -->
### ▼[方法3] シェルスクリプトから ansible-playbook コマンドを実行してプロビジョニング

```shell
$ cd ansible
$ bash provision_vagrant.sh
----------------------------------------------------------------------
[ provision_vagrant.sh ]
...
プロビジョニングを開始してもよろしいですか？ (y/n [n])
```

- シェルスクリプト内で [方法1] と同様のコマンドを呼び出している

  - ansible/provision_vagrant.sh

    ```shell
    TARGET_INVENTORY=vagrant
    TARGET_SITE=all_setup

    source $CURDIR/_provision.rc

    ansible-playbook -i $INVENTORY_FILE $SITE_FILE --extra-vars "$EXTRA_VARS" $ANSIBLE_OPT
    ```

  - ansible/_provision.rc

    ```shell
    ...
    cd $PLAYBOOK_DIR
    
    INVENTORY_FILE=$INVENTORIES/${TARGET_INVENTORY}_hosts.yml
    SITE_FILE=site_${TARGET_SITE}.yml
    ...
    ```

  - 注）ansible 実行時に ssh 接続で known_hosts の fingerprint 確認が行われることに注意
    - 過去に　vagrant destroy で VM を破棄していると実行に失敗してしまう
    - ansible/provision_vagrant.sh 内の下記の行を有効にすると、~/.ssh/known_hosts を強制的に書き換えて実行する
      - ansible/provision_vagrant.sh

        ```shell
        # Vagrant 専用処理
        # 注）~/.ssh/known_hosts を強制的に書き換えるので注意
        #force_update_known_hosts 192.168.56.11 testansible
        ```

        ↓

        ```shell
        # Vagrant 専用処理
        # 注）~/.ssh/known_hosts を強制的に書き換えるので注意
        # ↓のコメントを解除
        force_update_known_hosts 192.168.56.11 testansible
        ```

---
## ■セットアップ内容

- [testvagrant](https://github.com/gakimaru-on-connext/testvagrant#%E3%82%BB%E3%83%83%E3%83%88%E3%82%A2%E3%83%83%E3%83%97%E5%86%85%E5%AE%B9) と同じ

---
## ■各サーバーへのアクセス方法

- [testvagrant](https://github.com/gakimaru-on-connext/testvagrant#%E5%90%84%E3%82%B5%E3%83%BC%E3%83%90%E3%83%BC%E3%81%B8%E3%81%AE%E3%82%A2%E3%82%AF%E3%82%BB%E3%82%B9%E6%96%B9%E6%B3%95) 参照

- アクセス先のアドレスは 192.168.56.10 から 192.168.56.11 に変更する必要あり

---
## ■解説：Vagrant 設定

- [testvagrant](https://github.com/gakimaru-on-connext/testvagrant#%E8%A7%A3%E8%AA%AC-vagrant-%E8%A8%AD%E5%AE%9A) 参照

---
## ■解説：プロビジョニング

<!-- omit in toc -->
### ▼Vagrant プロビジョニング設定

- Vagrantfile

  ```ruby
  config.vm.provision :ansible do |ansible|
    playbook_dir = "../ansible/playbook"
    ansible.config_file = playbook_dir + "/ansible.cfg"
    ansible.playbook = playbook_dir + "/site_all_setup.yml"
    ansible.inventory_path = playbook_dir + "/inventories/vagrant_hosts.yml"
    ansible.limit = 'all'
    #ansible.verbose = "vvv"
    #ansible.tags = "tag1,tag2,..."
    #ansible.tags = "os,mariadb"
  end
  ```

<!-- omit in toc -->
### ▼Ansible の使い方の特徴

- インベントリファイルは、一般的な ini 形式ではなく yml 形式を採用
- インベントリには group_vars を用いずに、一つのインベントリファイルに環境固有の変数をまとめて定義するスタイル
  - group_vars を用いる場合よりもシンプルでわかり易い
- 複数の環境向けのインベントリを用意することを考慮（vagrant専用としない）
  - ansible/playbook/inventories/ 以下では、環境別の設定と共通設定を分けて templates/ にインベントリの元データを定義
    - templates/_(環境名)_hosts.yml が環境別の設定
    - templates/common/__\*.yml が共通設定
  - ansible/inventories_setup.sh を実行すると、環境別の設定と共通設定を合成して、inventories/(環境名)_hosts.yml を出力する
    - ansible/inventories_verify.sh を実行すると、インベントリのエラーチェックおよび内容確認が可能
- プレイブックは個別にロール（roles）で構成し、サイトファイルでまとめて実行するスタイル
  - サーバーの役割ごとのプレイブックをまとめやすいため
- ansible-lint の標準規則に従った内容で構成
  - ansible/ansible_list.sh を実行すると、プレイブックのエラーチェックが可能
  - ansible/playbook/.ansible-lint にて、無視するエラーを設定

---
## ■解説：複数 VM の起動とプロビジョニング

<!-- omit in toc -->
### ▼[手順１] Vagrant を停止して VM を破棄

- Vagrantfile の設定を変更する前に、必ず VM の停止と破棄を行う

  ```shell
  $ cd vagrant
  $ vagrant halt
  ==> default: Attempting graceful shutdown of VM...
  $ vagrant destroy
      default: Are you sure you want to destroy the 'default' VM? [y/N] y
  ==> default: Destroying VM and associated drives...
  ```

<!-- omit in toc -->
### ▼[手順2] Vagrant の複数VM指定

- Vagrantfile を編集し、config.vm.define "(ホスト名)" 〜 end を有効にする 

  ```ruby
  # dfault host
  config.vm.box = "generic/rocky9"
  config.vm.network "private_network", ip: "192.168.56.11"
  #config.vm.network "forwarded_port", guest: 80, host: 41080 # http
  config.vm.provider :virtualbox do |vb|
    vb.name = "testansible01"
    vb.gui = false
    vb.memory = "2048"
    vb.cpus = 2
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  end

  ## host01
  #config.vm.define "host01" do |host01|
  #  host01.vm.box = "generic/rocky9"
  #  host01.vm.network "private_network", ip: "192.168.56.11"
  #  ...
  #end

  ## host02
  #config.vm.define "host02" do |host02|
  #  host02.vm.box = "generic/rocky9"
  #  host02.vm.network "private_network", ip: "192.168.56.12"
  #  ...
  #end
  ```

  ↓

  ```ruby
  # ↓をコメントアウト
  ## dfault host
  #config.vm.box = "generic/rocky9"
  #config.vm.network "private_network", ip: "192.168.56.11"
  ##config.vm.network "forwarded_port", guest: 80, host: 41080 # http
  #config.vm.provider :virtualbox do |vb|
  #  vb.name = "testansible01"
  #  vb.gui = false
  #  vb.memory = "2048"
  #  vb.cpus = 2
  #  vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  #  vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  #end

  # ↓のコメントを解除
  # host01
  config.vm.define "host01" do |host01|
    host01.vm.box = "generic/rocky9"
    host01.vm.network "private_network", ip: "192.168.56.11"
    ...
  end

  # ↓のコメントを解除
  # host02
  config.vm.define "host02" do |host02|
    host01.vm.box = "generic/rocky9"
    host01.vm.network "private_network", ip: "192.168.56.12"
    ...
  end
  ```

- Vagrantfile には複数 VM 設定をコメントアウトしているので、それを有効にする
- 注）サンプルではクラスター構成を示しているが、実際にパッケージのセットアップではクラスター構成にはしていない

<!-- omit in toc -->
### ▼[手順3] Vagrant のプロビジョニングを無効化

- Vagrantfile を編集し、config.vm.provision 〜 end を有効にする 

  ```ruby
  config.vm.provision :ansible do |ansible|
    playbook_dir = "../ansible/playbook"
    ansible.config_file = playbook_dir + "/ansible.cfg"
    ansible.playbook = playbook_dir + "/site_all_setup.yml"
    ansible.inventory_path = playbook_dir + "/inventories/vagrant_hosts.yml"
    ansible.limit = 'all'
    #ansible.verbose = "vvv"
    #ansible.tags = "tag1,tag2,..."
    #ansible.tags = "os,mariadb"
  end
  ```

  ↓

  ```ruby
  #config.vm.provision :ansible do |ansible|
  #  playbook_dir = "../ansible/playbook"
  #  ansible.config_file = playbook_dir + "/ansible.cfg"
  #  ansible.playbook = playbook_dir + "/site_all_setup.yml"
  #  ansible.inventory_path = playbook_dir + "/inventories/vagrant_hosts.yml"
  #  ansible.limit = 'all'
  #  #ansible.verbose = "vvv"
  #  #ansible.tags = "tag1,tag2,..."
  #  #ansible.tags = "os,mariadb"
  #end
  ```

  - vagrant では、VM を１台セットアップするごとにプロビジョニングを実行してしまう
  - Ansible で全マシンをまとめてセットアップするため、vagrant によるプロビジョニングを無効化して扱う
  - 編集後、インベントリの更新を実行
  
    ```shell
    $ cd ansible
    $ bash inventories_setup.sh
    ```

<!-- omit in toc -->
### ▼[手順4] インベントリの設定を変更し、複数ホストに対応

- ansible/inventories/template_/_vagrant_hosts.yml

  ```yaml
    # --------------------
    # ホスト（物理）
    # --------------------
    # ホスト01
    host_01:
      hosts:
        192.168.56.11:
          host_name: testansible01
          ansible_host: 192.168.56.11
          ansible_port: 22
          ansible_user: vagrant
          ansible_ssh_private_key_file: "{{ playbook_dir }}/../../vagrant/.vagrant/machines/default/virtualbox/private_key"
          # ansible_ssh_private_key_file: "{{ playbook_dir }}/../../vagrant/.vagrant/machines/host01/virtualbox/private_key"
    # ホスト02
    host_02:
      hosts:
        # 192.168.56.12:
        #   host_name: testansible02
        #   ansible_host: 192.168.56.12
        #   ansible_port: 22
        #   ansible_user: vagrant
        #   ansible_ssh_private_key_file: "{{ playbook_dir }}/../../vagrant/.vagrant/machines/host02/virtualbox/private_key"
  ```

  ↓

  ```yaml
    # --------------------
    # ホスト（物理）
    # --------------------
    # ホスト01
    host_01:
      hosts:
        192.168.56.11:
          host_name: testansible01
          ansible_host: 192.168.56.11
          ansible_port: 22
          ansible_user: vagrant
          # ↓のコメント行を変更
          # ansible_ssh_private_key_file: "{{ playbook_dir }}/../../vagrant/.vagrant/machines/default/virtualbox/private_key"
          ansible_ssh_private_key_file: "{{ playbook_dir }}/../../vagrant/.vagrant/machines/host01/virtualbox/private_key"
    # ↓のコメントを解除
    # ホスト02
    host_02:
      hosts:
        192.168.56.12:
          host_name: testansible02
          ansible_host: 192.168.56.12
          ansible_port: 22
          ansible_user: vagrant
          ansible_ssh_private_key_file: "{{ playbook_dir }}/../../vagrant/.vagrant/machines/host02/virtualbox/private_key"
  ```

<!-- omit in toc -->
### ▼[手順5] VM を起動

```shell
$ cd vagrant
$ vagrant up --no-provision
```

<!-- omit in toc -->
### ▼[手順6] known_hosts 対策

- 過去に複数 VM の vagrant destroy を行ったことがある場合、プロビジョニングに失敗するため、下記のファイルを更新して known_hosts を強制的に更新するように指定する

  - ansible/provision_vagrant.sh

    ```shell
    # Vagrant 専用処理
    # 注）~/.ssh/known_hosts を強制的に書き換えるので注意
    #force_update_known_hosts 192.168.56.11 testansible
    #force_update_known_hosts 192.168.56.11 testansible01
    #force_update_known_hosts 192.168.56.12 testansible02
    ```

    ↓

    ```shell
    # Vagrant 専用処理
    # 注）~/.ssh/known_hosts を強制的に書き換えるので注意
    #force_update_known_hosts 192.168.56.11 testansible
    # ↓のコメントを解除
    force_update_known_hosts 192.168.56.11 testansible01
    force_update_known_hosts 192.168.56.12 testansible02
    ```

<!-- omit in toc -->
### ▼[手順7] プロビジョニング

```shell
$ cd ansible
$ bash provision_vagrant.sh
```

---
## ■ディレクトリ構成

```shell
testansible/
├── README.html
├── README.md
├── ansible/                                      # Ansible 用
│   ├── playbook/                                 # Ansible プレイブック用
│   │   ├── inventories/                          # Ansible インベントリ用
│   │   │   ├── templates/                        # Ansible インベントリテンプレート用
│   │   │   │   ├── common/                       # Ansible インベントリ共通テンプレート
│   │   │   │   │   ├── __footer.yml
│   │   │   │   │   ├── __groups.yml
│   │   │   │   │   ├── __header.yml
│   │   │   │   │   └── __vars.yml
│   │   │   │   └── _(環境名)_hosts.yml            # Ansible インベントリ環境別テンプレート
│   │   │   └── (環境名)_hosts.yml                 # Ansible インベントリ（環境別）
│   │   ├── roles/                                # Ansible ロール用
│   │   │   ├── info_inventory/                   # Ansible ロール：インベントリ情報出力
│   │   │   │   └── tasks/
│   │   │   │       └── main.yml
│   │   │   ├── os_base_setup/                    # Ansible ロール：OS 基本セットアップ
│   │   │   │   ├── tasks/
│   │   │   │   │   └── main.yml
│   │   │   │   └── vars/
│   │   │   │       └── vars.yml
│   │   │   ├── os_user_setup/                    # Ansible ロール：OS ユーザーセットアップ
│   │   │   │   ├── authorized_keys
│   │   │   │   │   ├── add/
│   │   │   │   │   │   └── *.pub
│   │   │   │   │   └── del/
│   │   │   │   │       └── *.pub
│   │   │   │   ├── tasks/
│   │   │   │   │   └── main.yml
│   │   │   │   └── templates/
│   │   │   │       ├─ .bashrc.ext.j2
│   │   │   │       └── sudoers-user.j2
│   │   │   ├── package_mariadb_client_setup/     # Ansible ロール：パッケージ：MariaDB クライアントセットアップ
│   │   │   │   └── tasks/
│   │   │   │       └── main.yml
│   │   │   ├── package_mariadb_server_setup/     # Ansible ロール：パッケージ：MariaDB サーバーセットアップ
│   │   │   │   ├── handlers/
│   │   │   │   │   └── main.yml
│   │   │   │   ├── tasks/
│   │   │   │   │   ├── main.yml
│   │   │   │   │   └── restart_mariadb_server.yml
│   │   │   │   └── vars/
│   │   │   │       └── vars.yml
│   │   │   ├── package_mongodb_client_setup/     # Ansible ロール：パッケージ：MongoDB クライアントセットアップ
│   │   │   │   └── tasks/
│   │   │   │       └── main.yml
│   │   │   ├── package_mongodb_common_setup/     # Ansible ロール：パッケージ：MongoDB 共通セットアップ
│   │   │   │   ├── files/
│   │   │   │   │   ├── mongodb-org-6.0-redhat8.repo
│   │   │   │   │   └── mongodb-org-6.0-redhat9.repo
│   │   │   │   ├── tasks/
│   │   │   │   │   └── main.yml
│   │   │   │   └── vars/
│   │   │   │       └── vars.yml
│   │   │   ├── package_mongodb_server_setup/     # Ansible ロール：パッケージ：MongoDB サーバーセットアップ
│   │   │   │   ├── handlers/
│   │   │   │   │   └── main.yml
│   │   │   │   ├── tasks/
│   │   │   │   │   ├── main.yml
│   │   │   │   │   └── restart_mongodb_server.yml
│   │   │   │   └── vars/
│   │   │   │       └── vars.yml
│   │   │   ├── package_nginx_server_setup/       # Ansible ロール：パッケージ：Nginx サーバーセットアップ
│   │   │   │   ├── handlers/
│   │   │   │   │   └── main.yml
│   │   │   │   └── tasks/
│   │   │   │       ├── main.yml
│   │   │   │       └── restart_nginx_server.yml
│   │   │   ├── package_nodejs_setup/             # Ansible ロール：パッケージ：Node.js セットアップ
│   │   │   │   └── tasks/
│   │   │   │       └── main.yml
│   │   │   ├── package_postgresql_client_setup/  # Ansible ロール：パッケージ：PostgreSQL クライアントセットアップ
│   │   │   │   └── tasks/
│   │   │   │       └── main.yml
│   │   │   ├── package_postgresql_server_setup/  # Ansible ロール：パッケージ：PostgreSQL サーバーセットアップ
│   │   │   │   ├── handlers/
│   │   │   │   │   └── main.yml
│   │   │   │   ├── tasks/
│   │   │   │   │   ├── main.yml
│   │   │   │   │   └── restart_postgresql_server.yml
│   │   │   │   └── vars/
│   │   │   │       └── vars.yml
│   │   │   ├── package_redis_client_setup/       # Ansible ロール：パッケージ：Redis クライアントセットアップ
│   │   │   │   └── tasks/
│   │   │   │       └── main.yml
│   │   │   └── package_redis_server_setup/       # Ansible ロール：パッケージ：Redis サーバーセットアップ
│   │   │       ├── handlers/
│   │   │       │   └── main.yml
│   │   │       ├── tasks/
│   │   │       │   ├── main.yml
│   │   │       │   └── restart_redis_server.yml
│   │   │       └── vars/
│   │   │           └── vars.yml
│   │   ├── vars/                                 # Ansible 共通変数用
│   │   │   └── common_vars.yml
│   │   ├── .ansible-lint                         # Ansible-lint 設定
│   │   ├── ansible.cfg                           # Ansible 基本設定
│   │   ├── playbook_info_print.yml               # Ansible プレイブック：情報表示
│   │   ├── playbook_os_setup.yml                 # Ansible プレイブック：OSセットアップ
│   │   ├── playbook_package_mariadb_setup.yml    # Ansible プレイブック：MariaDB セットアップ
│   │   ├── playbook_package_mongodb_setup.yml    # Ansible プレイブック：MongoDB セットアップ
│   │   ├── playbook_package_nginx_setup.yml      # Ansible プレイブック：Nginx セットアップ
│   │   ├── playbook_package_nodejs_setup.yml     # Ansible プレイブック：Node.js セットアップ
│   │   ├── playbook_package_postgresql_setup.yml # Ansible プレイブック：PostgreSQL セットアップ
│   │   ├── playbook_package_redis_setup.yml      # Ansible プレイブック：Redis セットアップ
│   │   └── site_all_setup.yml                    # Ansible サイト：全セットアップ
│   ├── _env.rc
│   ├── _provision.rc
│   ├── ansible_lint.sh                           # Ansible-lint 実行スクリプト
│   ├── ansible_lint_result.txt                   # Ansible-lint 実行結果
│   ├── inventories_setup.sh                      # Ansible インベントリセットアップスクリプト
│   ├── inventories_verify.sh                     # Ansible インベントリ検証スクリプト
│   └── provision_(環境名).sh                      # Ansible 実行スクリプト
└── vagrant/                                      # vagrant 用
    ├── share/                                    # vagrant 共有ディレクトリ
    └── Vagrantfile                               # vagrant VM 設定
```

----
以上
