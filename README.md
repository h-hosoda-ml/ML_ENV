# ML_ENV
## 概要
GPUサーバー上でML環境を構築するため、基盤となるDockerfileやその他テキストファイル群をまとめたリポジトリ

## 使い方
### Setup
`shell/` 配下のシェルスクリプト群に実行権限の付与を行う
```
chmod +x ./shell/*.sh
```
<br>

**(任意)** `./shell/run_container.sh`のデバイスを直接指定して複数GPUの指定を行う
```./shell/run_container.sh
docker container run -dit --rm \
    --name ${container_name} \
    --gpus '"device=0"' \ ← ここの部分を変更 (ex device=0,1)
    ${image_name}
```

お好みでコンテナにアタッチする部分のコメントアウト行う
```./shell/run_container.sh
docker exec -it ${container_name} /bin/bash ← ここの部分を変更
```
<br>

### Build Image
`./shell/build_image.sh` の実行を行い**イメージをビルド**する
```
./shell/build_image.sh {image_name}
```

任意のイメージ名をコマンドライン引数として指定できる。(※デフォルトは`ml_image`)
<br><br>

### Run Container
`./shell/run_container.sh` の実行を行い**コンテナを起動**する。
```
./shell/run_container.sh {image_name} {container_name}
```
任意のイメージ名とコンテナ名をコマンドライン引数として指定できる。<br>(※デフォルトは`ml_image`, `ml_container`)
