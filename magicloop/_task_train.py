#task
#class TestTrainTask(luigi.Task):
#    root_path = luigi.Parameter()
#    seed = luigi.Parameter()
#     validation_size = luigi.Parameter()
#
#     def requires(self):
#         logging.info("Requires TestTrainTask")
#         return IrisData()
#
#     def run(self):
#         logging.info("Start TestTrainTask")
#         #leer archivo
#         # transformar en df
#         logging.info("reading {}".format(self.input().path))
#         df = pd.read_csv(self.input().path)
#         logging.info("CSV readed")
#         # Split-out validation dataset
#         try:
#             X = df['sepal_length','sepal_width','petal_length','petal_width']
#             Y = df['class']
#             X_train, X_validation, Y_train, Y_validation = train_test_split(X, Y, test_size=validation_size, random_state=seed)
#             logging.info("Splitting data")
#
#             logging.info("creating {}".format(self.output()['iris_trainX'].path))
#             X_train.to_csv(self.output()['iris_trainX'].path)
#             logging.info("creating {}".format(self.output()['iris_testX'].path))
#             X_validation.to_csv(self.output()['iris_testX'].path)
#             logging.info("creating {}".format(self.output()['iris_trainY'].path))
#             Y_train.to_csv(self.output()['iris_trainY'].path)
#             logging.info("creating {}".format(self.output()['iris_testY'].path))
#             Y_validation.to_csv(self.output()['iris_testY'].path)
#         except Exception as e:
#             logging.error(e)
#
#     def output(self):
#         # output_path = '{}/iris.json'.format(self.root_path)
#         logging.info("Output TestTrainTask")
#         return { 'iris_trainX' : luigi.LocalTarget( self.root_path+"/iris_trainX.csv" ),
#                  'iris_testX' : luigi.LocalTarget( self.root_path+"/iris_testX.csv" ),
#                  'iris_trainY' : luigi.LocalTarget( self.root_path+"/iris_trainY.csv" ),
#                  'iris_testY' : luigi.LocalTarget( self.root_path+"/iris_testY.csv" ) }