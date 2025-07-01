## Baseline and AC-DC running documentation:
- <strong>Baselines Speed Test</strong>:
- - CNN: on sheephead, run /home/xijiang9/Desktop/baseline/Deep-Packet/looping_speed_eval.py which will store speed results at various flow rates under /home/xijiang9/Desktop/baseline/Deep-Packet/speed_results.txt
- - Conventional nprintgbm: 
- - - on grant, generate an initial model that uses all features first using data from /data/netmicroscope/service_recognition_data/conference_stream_media_other/aggregated, change the nprintml module to nprintml_org to save the model to /data/netmicroscope/service_recognition_data/final_models/. <strong>Do this only once</strong>.
- - - run /netmicroscope/service_recognition_data/Desktop/experiments/service_recognition/Codes/child-codes/efficient-classifier/feature_combination_testing.ipynb using bseline configuration to generate the baseline_experiment_str.txt
- - - switch to /cjiang/python-virtual-environments/env/lib64/python3.8/site-packages/nprintml_test for nprint module
- - - run /netmicroscope/service_recognition_data/Desktop/baseline/nprintml_gbm/experiment_runner-Copy1.ipynb to execute the inferences at different flow rates
- - - run /netmicroscope/service_recognition_data/Desktop/baseline/nprintml_gbm/result_reader.ipynb to parse the speed results together

- <strong>Baselines Mem Test</strong>:
- - CNN: on sheephead, turn off swap memory, /home/xijiang9/Desktop/baseline/Deep-Packet/loop_limit_test.py which will write all minimum mem requirements into mem_results.txt
- - Conventional nprintgbm: 
- - - Scp the generated all_features model to /home/xijiang9/Desktop/baseline/nprintml_gbm/models. <strong>Do this only once</strong>.
- - - on sheephead, run /home/xijiang9/Desktop/experiments/service_recognition/Codes/child-codes/efficient-classifier/feature_combination_testing.ipynb using bseline configuration to generate the baseline_experiment_str.txt
- - - turn off swap memory, run /home/xijiang9/Desktop/baseline/nprintml_gbm/exhaustive_mem_test/loop_limit_test.py which will store all results into mem_results.txt

- <strong>AC-DC Feature Requirement Computation</strong>:
- - on grant, /netmicroscope/service_recognition_data/Desktop/experiments/service_recognition/Codes/child-codes/efficient-classifier/feature_combination_testing.ipynb using ac-dc configuration to generate the final_grant_experiment_str.txt
- - on sheephead, run /home/xijiang9/Desktop/experiments/service_recognition/Codes/child-codes/efficient-classifier/feature_combination_testing.ipynb using ac-dc configuration to generate the final_mem_experiment_str.txt for flow rate varying data and also just the data from /data/netmicroscope/service_recognition_data/conference_stream_media_other/aggregated
- - run /netmicroscope/service_recognition_data/final_models/experiment_runner.ipynb to generate the models
- - scp the generated models to sheephead

- <strong>AC-DC Speed Computation</strong>:
- - on grant, under /netmicroscope/service_recognition_data/Desktop/experiments/exhaustive_speed_test_final, run experiment_runner.ipynb to execute the inferences
- - individual results at different targets and flow rates, i.e., batch sizes, are stored at /netmicroscope/service_recognition_data/Desktop/experiments/exhaustive_speed_test_final

- <strong>AC-DC Mem Computation</strong>:
- - on sheephead, turn off swap memory, run /home/xijiang9/Desktop/experiments/exhaustive_speed_test_final/loop_limit_test.py
- - mem limit results are store under mem_results.txt

- <strong>AC-DC Batch size and Feature Requirement Determination</strong>:
- - scp mem_results.txt from sheephead to grant under /data/netmicroscope/service_recognition_data/Desktop/experiments
- - run dataframe_generator.py to create initial metadata.
- - use eval_caller.py to evaluate the results.
