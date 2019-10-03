library(keras)

# instantiate the model
model <- application_resnet50(weights = 'assets/resnet50_weights_tf_dim_ordering_tf_kernels.h5')

# load the images
files <- list.files(path="data", pattern="*.*", full.names=TRUE, recursive=FALSE)

results <- lapply(files, function(x) {
    img_path <- x
    img <- image_load(img_path, target_size = c(224,224))
    x <- image_to_array(img)

    # ensure we have a 4d tensor with single element in the batch dimension,
    # the preprocess the input for prediction using resnet50
    x <- array_reshape(x, c(1, dim(x)))
    x <- imagenet_preprocess_input(x)

    # make predictions then decode and print them
    preds <- model %>% predict(x)
    return(imagenet_decode_predictions(preds, top = 1)[[1]])
})

# write the filenames and the results to disk
df <- data.frame(file=files, label=results)
write.csv(df, "submission.csv", row.names=FALSE)