IMAGE := gnuoctave/octave:9.2.0
DOCKER_RUN := docker run --rm -v $(PWD):/home/run -w /home/run $(IMAGE)

.PHONY: run train predict clean

run: ## Run complete pipeline (train + predict)
	mkdir -p output
	$(DOCKER_RUN) octave --no-gui --eval "isolated_run"

train: ## Train only
	mkdir -p output
	$(DOCKER_RUN) octave --no-gui --eval "train('input/trainData.csv', 'output/model.mat')"

predict: ## Predict only (requires trained model)
	mkdir -p output
	$(DOCKER_RUN) octave --no-gui --eval "predict_chap('output/model.mat', 'input/trainData.csv', 'input/futureClimateData.csv', 'output/predictions.csv')"

clean: ## Remove output files
	rm -rf output/*
