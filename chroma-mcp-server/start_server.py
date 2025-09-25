#!/usr/bin/env python3
"""
Startup script for Chroma MCP Server
"""

import asyncio
import sys
import os
from pathlib import Path

# Add the current directory to Python path
sys.path.insert(0, str(Path(__file__).parent))

from chroma_mcp_server import main

if __name__ == "__main__":
    print("Starting Chroma MCP Server...")
    print("Press Ctrl+C to stop the server")
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\nShutting down Chroma MCP Server...")
    except Exception as e:
        print(f"Error starting server: {e}")
        sys.exit(1)

