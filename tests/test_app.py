import unittest
import app
import numpy as np

class TestIrisModel(unittest.TestCase):
    def test_model_prediction(self):
        """Test if the model correctly predicts a valid class label."""
        sample_input = np.array([[5.1, 3.5, 1.4, 0.2]])
        prediction = app.model.predict(sample_input)[0]
        self.assertIn(prediction, [0, 1, 2])  # Should return a valid class

if __name__ == '__main__':
    unittest.main()
