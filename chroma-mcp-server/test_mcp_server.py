#!/usr/bin/env python3
"""
Test script for MCP Chroma Server
"""

import asyncio
import json
import subprocess
import sys
from pathlib import Path

async def test_mcp_server():
    """Test the MCP server with sample requests"""
    
    # Start the server process
    server_path = Path(__file__).parent / "mcp_chroma_server.py"
    process = subprocess.Popen(
        [sys.executable, str(server_path)],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )
    
    try:
        # Test requests
        test_requests = [
            {
                "method": "list_collections",
                "params": {}
            },
            {
                "method": "create_collection",
                "params": {
                    "name": "test_collection",
                    "metadata": {"test": True}
                }
            },
            {
                "method": "add_documents",
                "params": {
                    "collection_name": "test_collection",
                    "documents": [
                        "This is a test document about machine learning",
                        "Another document about artificial intelligence"
                    ],
                    "metadatas": [
                        {"topic": "ml"},
                        {"topic": "ai"}
                    ],
                    "ids": ["doc1", "doc2"]
                }
            },
            {
                "method": "query_collection",
                "params": {
                    "collection_name": "test_collection",
                    "query_texts": ["machine learning"],
                    "n_results": 2
                }
            },
            {
                "method": "get_collection_info",
                "params": {
                    "collection_name": "test_collection"
                }
            }
        ]
        
        print("Testing MCP Chroma Server...")
        print("=" * 50)
        
        for i, request in enumerate(test_requests, 1):
            print(f"\nTest {i}: {request['method']}")
            print(f"Request: {json.dumps(request, indent=2)}")
            
            # Send request
            process.stdin.write(json.dumps(request) + "\n")
            process.stdin.flush()
            
            # Read response
            response_line = process.stdout.readline()
            if response_line:
                response = json.loads(response_line.strip())
                print(f"Response: {json.dumps(response, indent=2)}")
            else:
                print("No response received")
        
        print("\n" + "=" * 50)
        print("Test completed!")
        
    except Exception as e:
        print(f"Error during testing: {e}")
    finally:
        # Clean up
        process.terminate()
        process.wait()

if __name__ == "__main__":
    asyncio.run(test_mcp_server())
