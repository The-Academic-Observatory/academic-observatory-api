# Copyright 2020-2022 Curtin University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Author: Aniek Roelofs, James Diprose

from __future__ import annotations

import os

from coki_api_base.app import create_app

# Create the Connexion App
config = {"JSON_SORT_KEYS": False, "JSONIFY_PRETTYPRINT_REGULAR": False}
openapi_spec_path = os.path.join(os.path.dirname(os.path.dirname(os.path.realpath(__file__))), "openapi.yaml.jinja2")
app = create_app(openapi_spec_path, config)

# Only called when testing locally
if __name__ == "__main__":
    app.run(debug=True)
