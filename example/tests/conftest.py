import logging
import pyspark
import pytest


def quiet_py4j():
    """ turn down spark logging for the test context """
    logger = logging.getLogger('py4j')
    logger.setLevel(logging.WARN)


@pytest.fixture(scope="session")
def spark_context(request):
    """ fixture for creating a spark context
    Args:
        request: pytest.FixtureRequest object
    """
    conf = pyspark.SparkConf(
    ).setMaster(
        "local"
    ).setAppName(
        "pytest-pyspark-local-testing"
    )
    sc = pyspark.SparkContext(conf=conf)
    request.addfinalizer(lambda: sc.stop())

    quiet_py4j()
    return sc
