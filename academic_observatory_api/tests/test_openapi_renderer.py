# Copyright 2022 Curtin University
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

# Author: Aniek Roelofs

import importlib
import os
import pathlib
import unittest

from coki_api_base.openapi_renderer import OpenApiRenderer


class TestOpenApiSchema(unittest.TestCase):
    def setUp(self) -> None:
        self.template_file = os.path.join(module_file_path("academic_observatory_api"), "openapi.yaml.jinja2")

    def test_validate_backend(self):
        """Test that the backend OpenAPI spec is valid"""
        renderer = OpenApiRenderer(self.template_file, usage_type="backend")
        renderer.validate_spec()

    def test_validate_cloud_endpoints(self):
        """Test that the cloud endpoints OpenAPI spec is valid"""

        renderer = OpenApiRenderer(self.template_file, usage_type="cloud_endpoints")
        renderer.validate_spec({"${host}": "api.observatory.academy", "${backend_address}": "192.168.1.1"})

    def test_validate_api_client(self):
        """Test that the API Client OpenAPI spec is valid"""

        renderer = OpenApiRenderer(self.template_file, usage_type="openapi_generator")
        renderer.validate_spec()


def module_file_path(module_path: str, nav_back_steps: int = -1) -> str:
    """Get the file path of a module, given the Python import path to the module.

    :param module_path: the Python import path to the module, e.g. observatory.platform.dags
    :param nav_back_steps: the number of steps on the path to step back.
    :return: the file path to the module.
    """

    module = importlib.import_module(module_path)
    file_path = pathlib.Path(module.__file__).resolve()
    return os.path.normpath(str(pathlib.Path(*file_path.parts[:nav_back_steps]).resolve()))
