//=======================================================================
// Copyright (c) 2016 Baptiste Wicht
// Distributed under the terms of the MIT License.
// (See accompanying file LICENSE or copy at
//  http://opensource.org/licenses/MIT)
//=======================================================================

#include <iostream>
#include <chrono>

#include "dll/neural/conv_layer.hpp"
#include "dll/neural/dense_layer.hpp"
#include "dll/pooling/mp_layer.hpp"
#include "dll/dbn.hpp"
#include "dll/trainer/stochastic_gradient_descent.hpp"

#include "mnist/mnist_reader.hpp"
#include "mnist/mnist_utils.hpp"

int main(int /*argc*/, char* /*argv*/ []) {
    auto dataset = mnist::read_dataset_direct<std::vector, etl::fast_dyn_matrix<float, 1, 28, 28>>();

    mnist::binarize_dataset(dataset);

    using dbn_t = dll::dbn_desc<
        dll::dbn_layers<
            dll::conv_desc<1, 28, 28, 10, 24, 24>::layer_t,
            dll::mp_layer_3d_desc<10, 24, 24, 1, 2, 2, dll::weight_type<float>>::layer_t,
            dll::conv_desc<10, 12, 12, 10, 8, 8>::layer_t,
            dll::mp_layer_3d_desc<10, 8, 8, 1, 2, 2, dll::weight_type<float>>::layer_t,
            dll::dense_desc<10 * 4 * 4, 150>::layer_t,
            dll::dense_desc<150, 10, dll::activation<dll::function::SOFTMAX>>::layer_t>,
        dll::momentum, dll::batch_size<64>, dll::trainer<dll::sgd_trainer>>::dbn_t;

    auto dbn = std::make_unique<dbn_t>();

    dbn->initial_momentum = 0.9;
    dbn->momentum = 0.9;

    dbn->display();

    auto ft_error = dbn->fine_tune(dataset.training_images, dataset.training_labels, 100);
    std::cout << "ft_error:" << ft_error << std::endl;

    auto test_error = dll::test_set(dbn, dataset.test_images, dataset.test_labels, dll::predictor());
    std::cout << "test_error:" << test_error << std::endl;

    return 0;
}
