# Ansible Test

## リポジトリ

- https://github.com/gakimaru-on-connext/testansible

## 概要

- Vagrant を用いた VM 上へのOSセットアップのテスト
- Ansible によるセットアップを行う

## 必要要件

- macOS ※x86系のみ
- 下記のインストールが行われていること
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

## Ansible プロビジョニング準備

- インベントリファイルを生成
  ```shell
  $ cd ansible
  $ bash inventories_setup.sh
  ```

- インベントリファイルを検証
  ```shell
  $ cd ansible
  $ bash inventories_verify.sh
  ```

- Playbook の内容・書き方エラーチェック
  ```shell
  $ cd ansible
  $ bash ansible_lint.sh
  ```

## VM 操作方法

### VM 起動

```shell
$ cd vagrant
$ vagrant up
```

- ※初回の VM 起動時には自動的にプロビジョニングも行われる

### プロビジョニング（セットアップ）

```shell
$ cd vagrant
$ vagrant provision
```

- これにより、Ansible が実行される（後述）

### VM 再起動

```shell
$ cd vagrant
$ vagrant reload
```

### VM 起動／再起動と同時にプロビジョニング

```shell
$ cd vagrant
$ vagrant up --provision
$ vagrant reload --provision
```

### VM 停止

```shell
$ cd vagrant
$ vagrant halt
```

### VM 破棄

```shell
$ cd vagrant
$ vagrant destroy
```

## Ansible プロビジョニング

### [方法1] 直接 ansible-playbook コマンドを実行してプロビジョニング

```shell
$ cd ansible/playbook
$ ansible-playbook -i inventories/vagrant_hosts.yml site_all_setup.yml
```

### [方法2] vagrant から ansible-playbook コマンドを実行してプロビジョニング

```shell
$ cd vagrant
$ vagrant provision
```

- Vagrantfile 内で [方法1] と同様のコマンドが実行されるように設定されている

  - vagrant/Vagrantfile

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

### [方法3] シェルスクリプトから ansible-playbook コマンドを実行してプロビジョニング

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

## セットアップ内容

### OS

- Rocky Linux 9
  - RedHat 9 互換
  - CentOS 後継 OS の一つ

### パッケージ

- MariaDB（MySQL互換のRDBサーバー）
- PostgreSQL（RDBサーバー）
- MongoDB（ドキュメントDBサーバー）
- Redis（キャッシュサーバー）
- Nginx（Webサーバー）
- Node.js（JavaScript開発・実行環境）

## 各サーバーへのアクセス方法（macOSからのアクセス）

### MariaDB

- 準備

```shell
$ brew install mysql-client
```

- 接続

```shell
$ mysql -u admin -h 192.168.56.10 --password=hogehoge mysql
mysql [admin@192.168.56.1 mysql] >
```

### PostgreSQL

- 準備

```shell
$ brew install libpq
$ echo 'export PATH=$PATH:/usr/local/opt/libpq/bin' >> ~/.zshrc
```

- 接続

```shell
$ psql -U admin -h 192.168.56.10 -d postgres
Password for user admin: hogehoge（パスワード入力）
postgres=>
```
または
```shell
$ psql 'postgres://admin:hogehoge@192.168.56.10:5432/postgres?sslmode=disable'
postgres=>
```

### MongoDB

- 準備

```shell
$ brew install mongsh
```

- 接続

```shell
$ mongosh 192.168.56.10
test>
```

### Redis

- 準備

```shell
$ brew install redis
```

- 接続

```shell
$ redis-cli -h 192.168.56.10
192.168.56.10:6379>
```

### Nginx

- 準備

```shell
$ brew install curl
```

- 接続

```shell
$ curl http://192.168.56.10
...(HTML出力)...
```

## ディレクトリ構成

- vagrant/ ... vagrant 用
  - Vagrantfile ... vagrant VM 設定
- ansible/ ... Ansible 用
  - playbook/ ... Ansible プレイブック用
    - inventories/ ... Ansible インベントリ用
      - templates/ ... Ansible インベントリテンプレート用
        - ***/ ...
    - roles/ ... Ansible ロール用
      - 
    - playbook_***.yml ... 
    - site_***.yml ... 
  - ****.sh ... 
  - ****.sh ... 
  - ****.sh ... 

## 解説

### Vagrant の　OS イメージの指定

- Vagrantfile 内の config.vm.box にて、VM の OS イメージを指定
  ```ruby
  config.vm.box = "generic/rocky9"
  ```

### Ansible の使い方の特徴

- インベントリファイルは、一般的な ini 形式ではなく yml 形式を採用
- インベントリには group_vars を用いずに、一つのインベントリファイルに環境固有の変数をまとめて定義するスタイル
  - group_vars を用いる場合よりもシンプルでわかり易い
- 複数の環境向けのインベントリを用意することを考慮し、環境固有の設定と共通設定を分けて ansible/playbook/inventories/templates/_*.yml に定義し、ansible/inventories_setup.sh によってそれらを合成して ansible/playbook/inventories/*.yml を出力
- ansible-lint の標準規則に従った内容で構成
- プレイブックは roles と site で構成
  - サーバーの役割ごとのプレイブックをまとめやすいため

----
以上
