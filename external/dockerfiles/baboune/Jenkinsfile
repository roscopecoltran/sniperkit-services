#!groovy

/*
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

node('node') {


    currentBuild.result = "SUCCESS"

    try {

       stage 'Checkout'

            git clone https://github.com/baboune/dockerimages.git
     

       stage 'Build Docker'

            cd er-jenkins
            sh build.sh 

       stage 'Deploy'

            echo 'Push to Repo'

            cd ..            

       stage 'Cleanup'

            echo 'prune and cleanup'

        }


    catch (err) {

        currentBuild.result = "FAILURE"

        throw err
    }

}