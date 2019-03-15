//https://github.com/tensorflow/swift/blob/master/Installation.md
//sudo apt update
//sudo apt-get install clang libpython-dev libblocksruntime-dev
//wget https://storage.googleapis.com/s4tf-kokoro-artifact-testing/latest/swift-tensorflow-DEVELOPMENT-ubuntu18.04.tar.gz
//tar xvzf swift-tensorflow-DEVELOPMENT-ubuntu18.04.tar.gz
//export PATH=$(pwd)/usr/bin:"${PATH}"
//using inference.swift template from https://github.com/tensorflow/swift/blob/master/Usage.md

import TensorFlow

struct MLPClassifier {
    var inpw = Tensor<Float>(shape: [2, 2], scalars: [0.15,0.25,0.20,0.3])
    var hidw = Tensor<Float>(shape: [2, 2], scalars: [0.4,0.5,0.45,0.55])
    var b1 = Tensor<Float>([0.35])
    var b2 = Tensor<Float>([0.6])

    func prediction(for x: Tensor<Float>) -> Tensor<Float> {
        let o1 = 1/(1+exp(-(matmul(x, inpw) + b1)))
        return 1/(1+exp(-(matmul(o1, hidw) + b2)))
    }
}

let inp = Tensor<Float>([[0.05,0.10]])
let classifier = MLPClassifier()
let prediction = classifier.prediction(for: inp)
print(prediction)

//sudo apt install python3-pip
//sudo pip3 install jupyter
//git clone https://github.com/google/swift-jupyter.git
//cd swift-jupyter/
//sudo pip3 install -r requirements.txt
//sudo pip3 install -r requirements_py_graphics.txt
//sudo python3 register.py --sys-prefix --swift-toolchain $HOME
//jupyter notebook
//%include "EnableIPythonDisplay.swift
//let np = Python.import("numpy")
//let plt = Python.import("matplotlib.pyplot")
//IPythonDisplay.shell.enable_matplotlib("inline")
//check
//animeshs@DMED7596:~/Desktop/scripts$ swift -O ann_tf.swift
//[[0.75136507, 0.7729285]]
//coding https://mattmazur.com/2015/03/17/a-step-by-step-backpropagation-example/ with swift-tensorflow, checking with iterative version at  https://github.com/animesh/ann/blob/master/ann/Program.cs with following output
//#Iteration = 1   Error = 0.298371108760003       Outputs = 0.751365069552316     0.772928465321463
