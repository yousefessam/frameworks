#!/bin/bash

#=======================================================================
# Copyright (c) 2016 Baptiste Wicht
# Distributed under the terms of the MIT License.
# (See accompanying file LICENSE or copy at
#  http://opensource.org/licenses/MIT)
#=======================================================================

######################
# Experiment 6 (CPU) #
######################

exp=6
mode=gpu

echo "Starting experiment $exp ($mode)"

#  Caffe  #
###########

echo "Starting Caffe"

mkdir -p results/$exp/$mode/caffe

cd caffe

export CAFFE_ROOT="/home/wichtounet/dev/caffe-cpu"

before=`date "+%s"`
$CAFFE_ROOT/build/tools/caffe train --solver=experiment6_solver_gpu.prototxt | tee ../results/$exp/$mode/caffe/raw_results
after=`date "+%s"`
echo "Time: $((after - before))"

cd ..

#  TF  #
########

echo "Starting TensorFlow"

mkdir -p results/$exp/$mode/tf

cd tf

source ~/.virtualenvs/tf2/bin/activate

before=`date "+%s"`
CUDA_VISIBLE_DEVICES=0 python experiment6.py | tee ../results/$exp/$mode/tf/raw_results
after=`date "+%s"`
echo "Time: $((after - before))"

deactivate

cd ..

#  Keras  #
###########

echo "Starting Keras"

mkdir -p results/$exp/$mode/keras

cd keras

source ~/.virtualenvs/tf2/bin/activate

before=`date "+%s"`
CUDA_VISIBLE_DEVICES=0 python experiment6.py | tee ../results/$exp/$mode/keras/raw_results
after=`date "+%s"`
echo "Time: $((after - before))"

deactivate

cd ..

#  DeepLearning4J  #
####################

echo "Starting DeepLearning4j"

mkdir -p results/$exp/$mode/dl4j

cd dl4j

export DL4J_MODE=cuda-8.0
mvn clean install > /dev/null

cd target/classes

before=`date "+%s"`
java -cp ../ihatejava-0.7-SNAPSHOT-bin.jar wicht.experiment6 | tee ../results/$exp/$mode/dl4j/raw_results
after=`date "+%s"`
echo "Time: $((after - before))"

cd ../..

cd ..

#  Torch  #
###########

echo "Starting Torch"

mkdir -p results/$exp/$mode/torch

cd torch

source ~/torch/install/bin/torch-activate

before=`date "+%s"`
th experiment6_gpu.lua | tee ../results/$exp/$mode/torch/raw_results
after=`date "+%s"`
echo "Time: $((after - before))"

cd ..