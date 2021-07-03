package main

import (
	"bufio"
	"bytes"
	"fmt"
	"io/ioutil"
	"log"
	"net"
	"net/http"
	"strings"

	"github.com/pkg/errors"
)

func main() {
	ln, err := net.Listen("tcp", ":8000")
	if err != nil {
		log.Fatal(err)
	}

	for {
		conn, err := ln.Accept()
		if err != nil {
			log.Println("accept:", err)
			continue
		}

		// TODO: Graceful shutdown
		go handle(conn)
	}
}

func handle(conn net.Conn) {
	defer println("exit handle")
	r := bufio.NewReader(conn)
	w := bufio.NewWriter(conn)
	for {
		if err := respondUrlData(w, r); err != nil {
			log.Println(err)
			return
		}
	}
}

func respondUrlData(w *bufio.Writer, r *bufio.Reader) error {
	url, err := r.ReadString('\n')
	if err != nil {
		return err
	}

	url = strings.Trim(url, "\n")

	fmt.Println(url)

	data, err := download(url)
	if err != nil {
		log.Println("download:", err)
		return nil
	}

	fmt.Println(len(data))

	n, err := w.Write(data)
	if err != nil {
		return errors.Wrap(err, "write")
	}

	if n != len(data) {
		return fmt.Errorf("incomplete write: want %v written %v", len(data), n)
	}

	// Flush buffered writer because response may be small
	if err = w.Flush(); err != nil {
		return errors.Wrap(err, "flush")
	}

	return nil
}

func download(url string) ([]byte, error) {
	resp, err := http.Get(url)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	data, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	// Cleanup response data
	data = append(bytes.Trim(data, "\n"), '\n')
	return data, nil
}
