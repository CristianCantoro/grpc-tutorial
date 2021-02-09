# Copyright 2015 gRPC authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""The Python implementation of the GRPC helloworld.Greeter client."""

from __future__ import print_function
import logging

import grpc
import argparse

import helloworld_pb2
import helloworld_pb2_grpc


def run(name):
    print('--- Starting gRPC client')
    channel = grpc.insecure_channel('server:50051')
    stub = helloworld_pb2_grpc.GreeterStub(channel)
    print("-> Send message: name={}".format(name))
    response = stub.SayHello(helloworld_pb2.HelloRequest(name=name))
    print("<- Greeter client received: " + response.message)
    print('--- Exiting gRPC client')


if __name__ == '__main__':
    logging.basicConfig()
    parser = argparse.ArgumentParser()
    parser.add_argument("--name",
                        default='World',
                        help="use this name for the greeting."
                        )
    args = parser.parse_args()

    try:
        run(args.name)
    except KeyboardInterrupt:
        pass

    exit(0)
